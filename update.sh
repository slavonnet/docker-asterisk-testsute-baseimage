#!/bin/bash


mkdir onbuild-pjproject_trunk-testsute_master
mkdir onbuild-pjproject_2.6-testsute_master

cp -f Dockerfile.template onbuild-pjproject_trunk-testsute_master/Dockerfile
cp -f Dockerfile.template onbuild-pjproject_2.6-testsute_master/Dockerfile

sed -i -e s!pjproject_branch=trunk!pjproject_branch=tags/2.6! onbuild-pjproject_2.6-testsute_master/Dockerfile



