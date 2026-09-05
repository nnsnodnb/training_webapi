# training_webapi

I wanted to learn some new technology, but building an API from scratch felt like a hassle, so I decided to build something that might be useful enough to actually use.

- [日本語README.md](README.ja.md)

## Environment

- macOS Taho (26.6.1)
  - M2 Ultra
- Docker version 29.7.2
- Container 1.2.2

## Getting Started

### macOS

<details>

<summary>Open</summary>

1. Download

From [Releases](https://github.com/nnsnodnb/training_webapi/releases/latest), select the CPU architecture that matches your environment, then download and extract `training-macOS-<your-arch>.zip`.

2. Migrate the database

```shell
cd /path/to/download_dir
./Training migrate --yes
```

Run the command above to migrate the database.  
This is generally only required the first time.

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

3. Start the application

```shell
./Training serve --env production --hostname 0.0.0.0 --port 8080
```

If the application starts and displays the following message, it is up and running.

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

You can access it at http://127.0.0.1:8080.
Good luck!

</details>

### Docker

<details>

<summary>Open</summary>

1. Install Docker

```shell
brew install --cask docker
```

2. Start the application

```shell
docker pull ghcr.io/nnsnodnb/training_webapi:latest
docker run -d -p 8080:8080 --name training-webapi ghcr.io/nnsnodnb/training_webapi:latest
```

3. Migrate the database

```shell
docker exec -t training-webapi /app/Training migrate --yes
```

Run the command above to migrate the database.
This is generally only required the first time.

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

4. Check the logs

```shell
docker logs training-webapi
```

If the application has started and displays the following message, it is up and running.

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

You can access it at http://127.0.0.1:8080.
Good luck!

</details>

### Container

<details>

<summary>Open</summary>

1. Install Container

https://github.com/apple/container#initial-install

2. Start the application

```shell
container i pull ghcr.io/nnsnodnb/training_webapi:latest
container run -d --rm --name training-webapi ghcr.io/nnsnodnb/training_webapi:latest
```

3. Migrate the database

```shell
container exec -t training-webapi /app/Training migrate --yes
```

Run the command above to migrate the database.  
This is generally only required the first time.

```shell
Migrate Command: Prepare
The following migration(s) will be prepared:
+ Training.InitialMigrations on <default>
+ Training.AddUserFieldInCommentMigrations on <default>
Would you like to continue?
y/n> yes
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.InitialMigrations]
[ INFO ] [Migrator] Starting prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
[ INFO ] [Migrator] Finished prepare [database-id: sqlite, migration: Training.AddUserFieldInCommentMigrations]
Migration successful
```

4. Check the logs

```shell
container logs training-webapi
```

If the application has started and displays the following message, it is up and running.

```
[ NOTICE ] Server started on http://0.0.0.0:8080
```

You can check the container's IP address with the following command:

```shell
container ls
ID               IMAGE                                                OS     ARCH   STATE    IP               CPUS  MEMORY   STARTED
training-webapi  training_webapi:latest                               linux  arm64  running  192.168.64.9/24  4     1024 MB  2026-08-19T05:50:10Z
```

In the example above, you can access the application at `http://192.168.64.9:8080`.
Good luck!

</details>

## API Specification

### Documentation

Users can create tasks and add comments to each task.  
Resources created by a user can only be accessed by the user who created them.

For detailed documentation, start the server as described in the sections above and access `http://{{ WebAPI IPv4 address }}/docs/swagger/index.html`.

### Authorization

Authorization is implemented using JWT.  
Send a username and password to `POST /v1/users/sign-in/` to obtain a refresh token (`refresh`) and an access token (`access`).

<details>

<summary>Example</summary>

```shell
curl -X POST http://127.0.0.1:8080/v1/users/sign-in/ \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"username\": \"sample-username\", \"password\": \"super-secret-password\"}"
```

</details>

### Expiration

- `refresh`: 1 week
- `access`: 1 hour

When the access token expires, send the refresh token to `/v1/users/refresh/` using refresh as the key.

### Serving Image Resources

This Web API supports handling images. Images are stored in a directory.  
They are stored under `/app/Public` inside the container.  
The size limit is 15 MB per upload.

- `/v1/tasks/`
- `/v1/tasks/{id}/`
- `/v1/tasks/{id}/comments/`
- `/v1/tasks/{id}/comments/{comment_id}/`

The image ID can be obtained from the response returned by the Web API. Combine this key with the host information to construct the URL.

<details>
<summary>Example</summary>

If the Web API returns the following:

```
/images/1B50BE9A-6D64-4F58-8287-267F873B7370/3E224D7F-9682-4156-AD53-8F77268F3C32.png
```

If the IP address of the machine running the Web API is `127.0.0.1`:

```
http://127.0.0.1:8080/images/1B50BE9A-6D64-4F58-8287-267F873B7370/3E224D7F-9682-4156-AD53-8F77268F3C32.png
```

Use the URL as shown above.

</details>

## WebSocket

You can receive real-time data via WebSocket when comments on tasks are updated.  
Like the Web API, authentication is required.

Below is an example connection using [wscat](https://github.com/websockets/wscat).  
Please replace `:taskID` and `${ACCESS_TOKEN}` with your own values.

```shell
wscat -c ws://127.0.0.1:8080/v1/tasks/:taskID/comments/ws \
       -H "Authorization: Bearer ${ACCESS_TOKEN}"
Connected (press CTRL+C to quit)
> 
```

This WebSocket endpoint only accepts PING messages. Any other messages sent will not be responded to.  
Data is pushed in the following cases:

- When a new comment is created (`POST /v1/tasks/:taskID/comments/`)
- When a comment is updated (`PUT /v1/tasks/:taskID/comments/:commentID`)
- When a comment is deleted (`DELETE /v1/tasks/:taskID/comments/:commentID`)

### Data Payload Format

1. When a new comment is created

```json
{
   "mode": "created",
   "comment": {...}
}
```

The structure of `comment` is the same as in the Web API response.

2. When a comment is updated

```json
{
   "mode": "modified",
   "comment": {...}
}
```

The structure of `comment` is the same as in the Web API response.

3. When a comment is deleted

```json
{
   "mode": "deleted",
   "comment_id": ":commentID"
}
```

## Cross-Origin Resource Sharing

The value of the `Origin` header in the request is allowed.

## Maintenance Mode

You can toggle maintenance mode using the commands below.

1. macOS

```shell
./Training maintenance on  # Enter maintenance mode
Maintenance mode is set to on
./Training maintenance off # Exit maintenance mode
Maintenance mode is set to off
```

2. Docker

```shell
docker exec -t training-webapi /app/Training maintenance on  # Enter maintenance mode
Maintenance mode is set to on
docker exec -t training-webapi /app/Training maintenance off # Exit maintenance mode
Maintenance mode is set to off
```

2. Container

```shell
container exec -t training-webapi /app/Training maintenance on  # Enter maintenance mode
Maintenance mode is set to on
container exec -t training-webapi /app/Training maintenance off # Exit maintenance mode
Maintenance mode is set to off
```

Accessing any endpoint will return a response similar to the following:

```json
{
  "error_detail": {
    "title": "The service is currently under maintenance.",
    "body": "Maintenance is scheduled to end at 2:00 AM on November 28, 2021."
  }
}
```

## Obtaining an Access Token

A command for debugging purposes is provided.  
Running the following command will retrieve an access token.

1. macOS

```shell
./Training access-token -u <your-user-id>
```

2. Docker


```shell
docker exec -t training-webapi /app/Training access-token -u <your-user-id>
```

3. Container

```shell
container exec -t training-webapi /app/Training access-token -u <your-user-id>
```

##  Run tests

```shell
swift test
```

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).
