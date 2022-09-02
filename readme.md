# The Android SDR Kit

## How to build

Clone the repository, cd to it and run the following command:

```sh
docker build --progress=plain -t android-sdr-kit .
```

This will give you an `android-sdr-kit` image that you can use to either create a containers with both tools and libraries, or simply extract the binaries for use elsewhere.

If you wish to run the container to build an app, use `docker run --name YourContainerName -it android-sdr-kit /bin/bash -l`

The `-l` being important to load the environment variables defined when the container was built.

## Credits

Credit to @Aang23 for the help getting some of the more annoying libs to work and for his work on getting volk fully working on android.