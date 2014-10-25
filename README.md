# kanburn


## Getting Started As a Developer

### Install meteor
``` sh
$ curl https://install.meteor.com | /bin/sh
```

### Configure your evironment variables
You will need to create a `env.sh` file in the `/config` directory of the project. This file defines
configuration and security settings. An example env file has been provided. Copy this file to
`env.sh` and fill in the values as needed.

### Source your environment variables
``` sh
$ source config/env.sh
```

### Start your server
If running on port 3000
``` sh
$ meteor
```

If running on a specific port
``` sh
$ meteor --port <port>
```
