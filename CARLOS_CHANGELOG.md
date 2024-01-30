## Latest : 1.0.0

## 1.0.0 - Initial Release

### Major changes

*   Created GitHub workflow and Dockerfile to automatically build Docker images
*   Update to Ubuntu 22.04 and Python 3.10 for prerequisites image
*   Update to Ubuntu 22.04 and Python 3.10 for release image
*   Created `vulkan-base` Dockerfile to replace discontinued `nvidia/vulkan` images used for the release image
*   Added health check to release image

### Minor changes

*   Added `ping.py` script to PythonAPI to enable health checks
*   Fix [aria2](https://aria2.github.io/) related issue
