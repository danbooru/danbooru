
# Troubleshooting

*Recommended steps to take when your setup isn't working.*

<br>

## PostgreSQL Database

Ensure you can connect to it with  `psql`  and the table exist.

If this fails, you need to work on correctly installing **PostgreSQL**, <br>
importing the initial schema, as well as running the migrations.

<br>
<br>

## Rails Database

<br>

Check the connection with the following command:

```sh
bin/rails console
```

<br>

Also make surre that **Rails** can connect to the database:

```
Post.count
```

<br>

If this fails, you need to make sure your <br>
**Danbooru** configuration files are correct.

<br>
<br>

## Nginx

Ensure it is working correctly, for this you <br>
may need to debug it's configuration files.

<br>
<br>

## Logs

Look through all log files.

<br>
