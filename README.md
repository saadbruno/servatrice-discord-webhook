# servatrice-discord-webhook
A simple way to push your Cockatrice Server updates do Discord

![image](https://user-images.githubusercontent.com/23201434/152206509-e8222c6e-cd02-4a4d-a3b0-239bac2ce87e.png)

This script will push your easily push:
- Server joins and leaves
- Created games

to a Discord Webhook easily, with minimal configuration

This script works by reading your server log file, parsing and formatting it using Discord rich embeds, and pushing it to the webhook endpoint.

## Initial Setup:
For this to work, you need to enable server log-to-file in your Servatrice configuration.

Open `servatrice.ini`
Make sure you have these two options set:
```
writelog=1
logfile=/path/to/servatrice.log
```

## Usage

### With Docker:

There's an image avaible on [Docker Hub](https://hub.docker.com/r/saadbruno/servatrice-discord-webhook)!

#### Note on bind mounts:
Since Docker bind mount individual files based on the inode, you have to **mount the entire log directory**, and reference the file inside that directory. That way the script doesn't loose track of the `servatrice.log` file if the log rotates.

TL;DR: Mount the log directory, not the log file.

#### Docker run:
`docker run --name servatrice-discord-webhook -v /path/to/server/logs:/app/logs:ro --env WEBHOOK_URL=https://discord.com/api/webhooks/111222333/aaabbbccc --env FOOTER=Optional\ Footer\ Text --env LANGUAGE=en-US saadbruno/servatrice-discord-webhook:latest`
> Note: FOOTER and LANGUAGE are optional

#### Docker Compose:
```
version: '3.3'
services:
    servatrice-discord-webhook:
        container_name: servatrice-discord-webhook
        volumes:
            - '/path/to/server/logs:/app/logs:ro'
        environment:
            - 'WEBHOOK_URL=https://discord.com/api/webhooks/111222333/aaabbbccc'
            - 'FOOTER=Optional Footer Text'
            - 'LANGUAGE=en-US'
        image: 'saadbruno/servatrice-discord-webhook:latest'
        restart: unless-stopped
```
> Note: FOOTER and LANGUAGE are optional

### Without Docker:
- Clone the repo
- run `WEBHOOK_URL=<discord webhook> SERVERLOG=</path/to/server/logs> FOOTER=<optional footer> LANGUAGE=<optional language> ./servatrice-discord.webook.sh`

## Variables:

- WEBHOOK_URL: it's the discord webhook you want the notifications posted to. Read more at [Discord Support](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)
- LANGUAGE: The language of the notifications. Check the [lang directory](https://github.com/saadbruno/servatrice-discord-webhook/tree/main/lang) for currently supported languages. Contributions are welcome!
- FOOTER: An optional footer text that will be included with the notifications, you can put your server name, server address or anything else. You can also ommit this for a more compact notification.
