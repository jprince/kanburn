# kanburn


## Getting Started As a Developer

### Install meteor
``` sh
$ curl https://install.meteor.com | /bin/sh
```

### Configure your evironment variables
You will need to create a `env.sh` file in the `/config` directory of the project. This file
defines configuration and security settings. An example env file has been provided. Copy this file to
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

### Seed your database with sample data (optional)
Note: Seeding tickets is only necessary if you're working offline; otherwise data from the JIRA
API feed will be used. Seeds for tickets and the release are added automatically by Meteor.

Install [MongoDB][].
[MongoDB]: http://www.mongodb.org/downloads

Copy the two ticket CSV files in the `server/samples` directory to the folder where you saved your
MongoDB download.

From within the `bin` directory of the MongoDB package, run:
```sh
./mongoimport -h localhost:3001 --db meteor --collection tickets --type csv --file ../../non_bug_tickets.csv --fields component,id,type,title,priority,status,points
./mongoimport -h localhost:3001 --db meteor --collection tickets --type csv --file ../../bug_tickets.csv --fields component,id,type,title,priority,status,points
```

If you fail to connect to the database, check your running processes to see which port your Meteor
DB is running on. Update `localhost:3001` in the above command to reflect the appropriate port.

### Deleting data
The following methods can be executed from the console:
- `Meteor.call('removeAllSettings')`
- `Meteor.call('removeAllTickets')` (if you've seeded your database with sample data)
- `Meteor.call('removeRelease')`
