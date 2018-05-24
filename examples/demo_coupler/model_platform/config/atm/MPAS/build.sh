#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

cd $exedir/MPAS/MPAS-Release-5.2/
make clean CORE=init_atmosphere
make clean CORE=atmosphere
make gfortran CORE=init_atmosphere USE_PIO2=true
make gfortran CORE=atmosphere USE_PIO2=true

cp $exedir/MPAS/MPAS-Release-5.2/atmosphere_model  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/init_atmosphere_model  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/*TBL  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/*DBL  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/*DATA  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/namelist.*  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/streams.*  $exedir/exe/mpas/
cp $exedir/MPAS/MPAS-Release-5.2/stream_list.*  $exedir/exe/mpas/
