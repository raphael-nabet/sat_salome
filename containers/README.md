
To compile and launch SALOME, please follow the steps below. This assumes that Docker is already installed on your workstation. If it is not, please refer to the official Docker documentation for installation instructions at this [link](https://docs.docker.com/desktop).
  

1. Construct the docker image

  ```bash
     docker build -t "salome-ub24.04-x86_64:latest" -f SALOMEPlatform.Dockerfile.ub24.04-x86_64 .
  ```
  
2.  Launch one container from this image

  ```bash
     docker run --rm -it --volume $PWD:$PWD --workdir $PWD salome-ub24.04-x86_64:latest
  ```

3. Construct SALOME in that container
 
  ```bash
     # Define a workspace
     export SALOME_WORKSPACE=$PWD

     # retrieve SAT and SAT_SALOME sources
     git clone https://github.com/SalomePlatform/sat.git SAT
     git clone https://github.com/SalomePlatform/sat_salome.git SAT_SALOME

     # Expose SAT_SALOME to SAT
     SAT/sat init --add_project $PWD/SAT_SALOME/salome.pyconf

     # Ensure required system dependencies are present, and install the missing ones, if any.
     SAT/sat config SALOME-master-native --check_system

     # Retrieve all SALOME modules sources as well as all the external dependencies
     SAT/sat -o "APPLICATION.properties.git_server='github'"  prepare SALOME-master-native

     # Compile SALOME from scratch
     SAT/sat -o "APPLICATION.properties.git_server='github'" compile SALOME-master-native

     # Once the compilation done, cleanup some directories
     rm -rf SALOME-master-native-UB24.04/BUILD ARCHIVES

     # Generate a SALOME launcher
     SAT/sat launcher SALOME-master-native --use_mesa

     # you can also package SALOME binary distribution and share it
     SAT/sat package SALOME-master-native -b 
  ```

4. Run the docker on the constructed SALOME

  ```bash
 
     # grant permission to local root user
     xhost +local:root

     # launch Docker
     docker run --rm                                            \
                --net host                                      \
                --env DISPLAY=$DISPLAY                          \
                --volume /tmp/.X11-unix:/tmp/.X11-unix:ro       \
                --volume $HOME/.Xauthority:/root/.Xauthority:rw \
                --volume $PWD:$PWD                              \
                salome-ub24.04-x86_64:latest                    \
                $PWD/SALOME-master-native-UB24.04/salome
   ```

  Here:
  
  - ``--rm``: deletes container once SALOME is exited.
  
  - ``--env DISPLAY=$DISPLAY``: passes the ``DISPLAY`` environment variable to the container, this basically tells SALOME which screen it should display on.
  
  - ``--volume /tmp/.X11-unix:/tmp/.X11-unix:ro``: Mounts the X11 server socket (the communication point) into the container in read-only  mode.
  
  - ``--volume $HOME/.Xauthority:/root/.Xauthority:rw``: shares the X authority file to manage display permissions more securely.
  
  - ``--net host`` : in case CORBA or some network is required.


  To check that everything is working as it should, run in the python console
  
  ```python
     from salome.kernel import salome_test
  ```

  Please note that for releases prior to or equal to SALOME 9.16.0, the command line reads:
  
  ```python
     import salome_test
  ```

  
  You can also run one module test suit, e.g GEOM:

  ```bash
     docker run --rm                                            \
                --net host                                      \
                --env DISPLAY=$DISPLAY                          \
                --volume /tmp/.X11-unix:/tmp/.X11-unix:ro       \
                --volume $HOME/.Xauthority:/root/.Xauthority:rw \
                --volume $PWD:$PWD                              \
                salome-ub24.04-x86_64:latest                    \
                $PWD/SALOME-master-native-UB24.04/salome test -R GEOM
  ```


## Apptainer / Singularity containers

On HPC clusters or workstations where Docker is not available, the same environment is provided as [Apptainer](https://apptainer.org/docs/user/latest/) (formerly Singularity) definition files: `SALOMEPlatform.<tag>.def`, one per Dockerfile, with the same system packages. The commands below use Ubuntu 24.04; replace `ub24.04-x86_64` / `UB24.04` with `ub26.04-x86_64` / `UB26.04` for Ubuntu 26.04. With a legacy Singularity installation, replace `apptainer` with `singularity`.

Main differences with Docker to keep in mind:

- the container runs as **your own user**, not root;
- `$HOME`, `/tmp` and the current directory are mounted automatically, other directories must be added with `--bind`;
- the image (`.sif` file) is **read-only**: system packages cannot be installed from inside the container;
- the host environment variables (including `DISPLAY`) are passed to the container.

1. Build the Apptainer image

  Building from a definition file requires root privileges, or `--fakeroot` if your administrator enabled it (see `/etc/subuid`):

  ```bash
     sudo apptainer build  SALOMEPlatform.ub24.04-x86_64.sif SALOMEPlatform.ub24.04-x86_64.def
  ```

  The result is a single file, `SALOMEPlatform.ub24.04-x86_64.sif`, that can be copied to any machine with Apptainer installed. Building and running do not need to happen on the same machine.

2. Construct SALOME in the container

  Choose a workspace directory with enough disk space for the sources, build and install trees, and open a shell in the container. Add `--bind` if the workspace is outside `$HOME`:

  ```bash
     # Define a workspace
     export SALOME_WORKSPACE=$PWD
     cd $SALOME_WORKSPACE
     apptainer shell --bind $SALOME_WORKSPACE SALOMEPlatform.ub24.04-x86_64.sif
  ```

  Then, inside the container (the prompt becomes `Apptainer>`):

  ```bash
     # retrieve SAT and SAT_SALOME sources
     git clone https://github.com/SalomePlatform/sat.git SAT
     git clone https://github.com/SalomePlatform/sat_salome.git SAT_SALOME

     # Expose SAT_SALOME to SAT
     SAT/sat init --add_project $PWD/SAT_SALOME/salome.pyconf

     # Check that all required system dependencies are present in the image
     SAT/sat config SALOME-master-native --check_system

     # Retrieve all SALOME modules sources as well as all the external dependencies
     SAT/sat -o "APPLICATION.properties.git_server='github'" prepare SALOME-master-native

     # Compile SALOME from scratch
     SAT/sat -o "APPLICATION.properties.git_server='github'" compile SALOME-master-native

     # Once the compilation done, cleanup some directories
     rm -rf SALOME-master-native-UB24.04/BUILD ARCHIVES

     # Generate a SALOME launcher
     SAT/sat launcher SALOME-master-native --use_mesa

     # leave the container
     exit
  ```

  Notes:

  - if `--check_system` reports missing packages, add them to the `.def` file, then rebuild the `.sif` image;
  - SAT stores its user configuration in `$HOME/.salomeTools`, which is shared with the host since `$HOME` is mounted;
  - if host environment variables (e.g. `PYTHONPATH`, `LD_LIBRARY_PATH` set by environment modules) interfere with the build, add `--cleanenv` to the `apptainer shell` command;
  - for a long build on a remote machine, the compilation can run without an interactive shell:

  ```bash
     apptainer exec --bind $SALOME_WORKSPACE SALOMEPlatform.ub24.04-x86_64.sif \
         $SALOME_WORKSPACE/SAT/sat -o "APPLICATION.properties.git_server='github'" compile SALOME-master-native
  ```

3. Run the constructed SALOME

  No X11 setup is needed: `DISPLAY` and `$HOME/.Xauthority` are taken from the host, which also works through `ssh -X`.

  ```bash
     cd $SALOME_WORKSPACE

     # Launch the SALOME GUI
     apptainer exec --bind $SALOME_WORKSPACE SALOMEPlatform.ub24.04-x86_64.sif \
         $SALOME_WORKSPACE/SALOME-master-native-UB24.04/salome

     # Run one module test suite, e.g. GEOM
     apptainer exec --bind $SALOME_WORKSPACE SALOMEPlatform.ub24.04-x86_64.sif \
         $SALOME_WORKSPACE/SALOME-master-native-UB24.04/salome test -R GEOM
  ```

  To check that everything works, run `from salome.kernel import salome_test` in the SALOME Python console (`import salome_test` for SALOME 9.16.0 and earlier).

  On a host with an NVIDIA GPU, add `--nv` to the `apptainer exec` command to use hardware-accelerated rendering. In that case, regenerate the launcher without `--use_mesa`.
