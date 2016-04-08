from os import remove
from os.path import isfile
from sys import platform
from setuptools import Extension, setup

import spine

try:
    from Cython.Build import cythonize
    have_cython = True
except ImportError:
    have_cython = False


if platform == 'win32':
    cstdarg = '-std=gnu99'
else:
    cstdarg = '-std=c99'

do_clear_existing = False

package_dir = {
    'spine': 'spine'
}

package_data = {
    'spine': [
        '*.pxd',
        'animation/*.pxd',
        'attachment/*.pxd',
        'skeleton/*.pxd'
    ]
}

packages = [
    'spine',
    'spine.animation',
    'spine.attachment',
    'spine.atlas',
    'spine.skeleton'
]

prefixes = {
    'spine': 'spine.',
    'animation': 'spine.animation.',
    'attachment': 'spine.attachment.',
    'skeleton': 'spine.skeleton.'
}

file_prefixes = {
    'spine': 'spine/',
    'animation': 'spine/animation/',
    'attachment': 'spine/attachment/',
    'skeleton': 'spine/skeleton/'
}

modules = {
    'spine': [
        'bone',
        'spineevent',
        'ikconstraint',
        'slot',
        'utils'
    ],
    'animation': [
        'animation',
        'animationstate',
        'attachmenttimeline',
        'colortimeline',
        'curvetimeline',
        'drawordertimeline',
        'eventtimeline',
        'ffdtimeline',
        'flipxtimeline',
        'flipytimeline',
        'ikconstrainttimeline',
        'rotatetimeline',
        'scaletimeline',
        'timeline',
        'trackentry',
        'translatetimeline'
    ],
    'attachment': [
        'attachment',
        'boundingboxattachment',
        'meshattachment',
        'skinnedmeshattachment',
        'regionattachment'
    ],
    'skeleton': [
        'skeleton',
        'skeletonbounds',
        'skeletondata'
    ]
}


core_modules = {}
core_modules_c = {}
check_for_removal = []
extensions = []
cmdclass = {}


for name in modules:
    file_prefix = file_prefixes[name]
    prefix = prefixes[name]
    module_files = modules[name]
    for module_name in module_files:
        prefix_module_name = prefix + module_name 
        file_prefix_module_name = file_prefix + module_name
        core_modules[prefix_module_name] = [file_prefix_module_name + '.pyx']
        core_modules_c[prefix_module_name] = [file_prefix_module_name + '.c']
        check_for_removal.append(file_prefix_module_name + '.c')


def build_ext(ext_name, files):
    return Extension(
        ext_name, files, [],
        extra_compile_args=[cstdarg, '-ffast-math']
    )


def build_extensions_for_modules_cython(ext_list, modules):
    ext_a = ext_list.append
    for module_name in modules:
        ext = build_ext(module_name, modules[module_name])
        ext_a(ext)
    return cythonize(ext_list)


def build_extensions_for_modules(ext_list, modules):
    ext_a = ext_list.append
    for module_name in modules:
        ext = build_ext(module_name, modules[module_name])
        ext_a(ext)
    return ext_list


if have_cython:
    if do_clear_existing:
        for file_name in check_for_removal:
            if isfile(file_name):
                remove(file_name)
    core_extensions = build_extensions_for_modules_cython(
        extensions, core_modules)
else:
    core_extensions = build_extensions_for_modules(extensions, core_modules_c)


setup(
    name='spine-cython',
    version=spine.__version__,
    author='Tileworks Games and other contributors.',
    author_email='tileworksgames@gmail.com',
    description='Spine runtimes for python.',
    long_description=spine.__doc__,
    license='Spine Runtimes Software License',
    ext_modules=core_extensions,
    cmdclass=cmdclass,
    packages=packages,
    package_dir=package_dir,
    package_data=package_data,
    keywords='spine',
    classifiers=[
        'Intended Audience :: Developers',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: Information Technology',
        'Programming Language :: Python :: 2.7',
        'Operating System :: Microsoft :: Windows',
        'Topic :: Games/Entertainment',
        'Topic :: Multimedia :: Graphics',
    ],
    setup_requries=['cython>=0.20']
)
