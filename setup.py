import sys
from setuptools import setup, find_packages


if sys.platform == 'win32':
    compile_args = ['-std=gnu99', '-ffast-math']
else:
    compile_args = ['-std=c99', '-ffast-math', '-w']
    libraries = []


setup(
    name='spine-cython',
    version='0.5.1-dev0',
    description='Spine runtimes for python.',
    author='Tileworks Games and other contributors.',
    author_email='tileworksgames@gmail.com',
    packages=find_packages(),
    package_data={
        '': ['*.pxd']
        },
    setup_requires=['cython', 'setuptools.autocythonize'],
    auto_cythonize={
        'compile_args': compile_args,
    },
    keywords=['spine', 'animation', 'game'],
    classifiers=[
        'Intended Audience :: Developers',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: Information Technology',
        'Programming Language :: Python :: 2.7',
        'Operating System :: Microsoft :: Windows',
        'Topic :: Games/Entertainment',
        'Topic :: Multimedia :: Graphics'
    ]
)
