Bootstrap: docker
From: ubuntu:latest
Stage: devel

# Install binary into final image
#%files from devel
#    /opt/hand_taudem_docker.git/mpitest.c /opt

%environment
    # Point to MPICH binaries, libraries, man pages
    export MPICH_DIR=/opt/mpich-3.2.1
    export PATH="$MPICH_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$MPICH_DIR/lib:$LD_LIBRARY_PATH"
    export MANPATH="$MPICH_DIR/share/man:$MANPATH"

%post
    echo "Installing required packages..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get install -y wget git bash gcc gfortran g++ make

    ## Information about the version of MPICH to use
    export MPICH_VERSION=3.2.1
    export MPICH_URL="http://www.mpich.org/static/downloads/$MPICH_VERSION/mpich-$MPICH_VERSION.tar.gz"
    export MPICH_DIR=/opt/mpich

    echo "Installing MPICH..."
    mkdir -p /tmp/mpich
    mkdir -p /opt
    ## Download
    cd /tmp/mpich && wget -O mpich-$MPICH_VERSION.tar.gz $MPICH_URL && tar xzf mpich-$MPICH_VERSION.tar.gz
    ## Compile and install
    cd /tmp/mpich/mpich-$MPICH_VERSION && ./configure --prefix=$MPICH_DIR && make install
    ## Set env variables so we can compile our application
    export PATH=$MPICH_DIR/bin:$PATH
    export LD_LIBRARY_PATH=$MPICH_DIR/lib:$LD_LIBRARY_PATH

    echo "Compiling the MPI application..."
    cd /opt && mpicc -o mpitest /opt/hand_taudem_docker.git/mpitest.c

