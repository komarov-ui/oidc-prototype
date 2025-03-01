# oidc-prototype

**Frontend Application**: https://github.com/komarov-ui/react-oidc-prototype

**Backend Service**: https://github.com/komarov-ui/nodejs-oidc-prototype

## Create SSL self-signed certificate

1. Go to `https://slproweb.com/products/Win32OpenSSL.html`.

    **NOTE:** OpenSSL Light is enough for our purposes.

2. Download OpenSSL for Windows x64 and install it.

3. Update your PATH env variable in Windows. Add new row with value: `<Path to OpenSSL>/bin`. Save.

    **NOTE:** Replace `<Path to OpenSSL>` with path to folder where OpenSSL installed on your computer.

4. Do checking in PowerShell: `opensll version`. If there is an OpenSSL version - it's OK, keep going.

5. Go to folder `create-ssl-certs` (previously, you have to clone project or download it as ZIP-archive).

6. Open PowerShell in this folder and run `./generate-cert.ps1`.

    **NOTE:** If you are not allowed to run, you may try following command in the same folder:

    ```
    powershell -ExecutionPolicy Bypass -File .\generate-cert.ps1
    ```

7. If there are 2 files `server.key` and `server.crt` - it`s OK, keep going.

8. Double-click on `server.crt` to install certificate.

    1) Click "Install certificate" button.

    2) Select "Current user".

    3) "Place all certificates in the following store".

    4) Click on "Browse" and select "Trusted Root Certification Authorities".

    5) Click on "Next" and then click on "Finish".

    6) Allow Windows to install self-signed certificate.

9. Create folder `ssl` in root of projects `react-oidc-prototype` and `nodejs-oidc-prototype`. Put `server.key` and `server.crt` in there (copy them there).

    **OR** you can go with alternative way and just change paths to certs in these projects.

    * **vite.config.ts** - in `react-oidc-prototype`
    * **app.js** - in `nodejs-oidc-prototype` (almost end of the file)

## Running Keycloak Server

Before running frontend and backend service, you must raise up *Keycloak Server*.

It's really simple to do with following Docker command in **Windows PowerShell**.

**NOTE:** Replace `<path_to_folder_with_certs>` to appropriate path in commands.

```powershell
docker run `
  -p 8443:8443 `
  -p 9000:9000 `
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin `
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me `
  -e KC_HTTPS_CERTIFICATE_FILE=/opt/keycloak/conf/server.crt `
  -e KC_HTTPS_CERTIFICATE_KEY_FILE=/opt/keycloak/conf/server.key `
  -v C:/<path_to_folder_with_certs>/server.crt:/opt/keycloak/conf/server.crt `
  -v C:/<path_to_folder_with_certs>/server.key:/opt/keycloak/conf/server.key `
  quay.io/keycloak/keycloak:26.1.2 `
  start `
  --hostname=localhost
```

If you use Podman instead of Docker, command will be almost the same:

```powershell
podman run `
  -p 8443:8443 `
  -p 9000:9000 `
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin `
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me `
  -e KC_HTTPS_CERTIFICATE_FILE=/opt/keycloak/conf/server.crt `
  -e KC_HTTPS_CERTIFICATE_KEY_FILE=/opt/keycloak/conf/server.key `
  -v C:/<path_to_folder_with_certs>/server.crt:/opt/keycloak/conf/server.crt `
  -v C:/<path_to_folder_with_certs>/server.key:/opt/keycloak/conf/server.key `
  quay.io/keycloak/keycloak:26.1.2 `
  start `
  --hostname=localhost
```

It will run your Keycloak Server on address: `https://localhost:8443`
Path to Admin Console: `https://localhost:8443/admin/master/console/`
Credentials for Admin Console:

- Username: `admin`
- Password: `change_me`

This instance of Keycloak Server is run in production mode with enabled HTTPS.

After first starting up Keycloak Server you will be able to configure it Admin Console and save changes by commiting changed container as image by command:

```
docker commit <CONTAINER_ID> <IMAGE_NAME>:<IMAGE_TAG>
```

If you use Podman instead of Docker, command will be almost the same:

```
podman commit <CONTAINER_ID> <IMAGE_NAME>:<IMAGE_TAG>
```

You can use this image instead of `quay.io/keycloak/keycloak:26.1.2` and use flag `--optimized`.

## Adjusting Keycloak Server

Go to Admin Console ( `https://localhost:8443/admin/master/console/`).

### Create realm

1. Sign In with provided default credentials.

2. Click on realms dropdown at the top-left corner.

3. Click on "Create realm".

4. Put "oidc-app" in "Realm name" and click "Create".

### Create user

1. Select "oidc-app" in realms dropdown.

2. Go to "Users" tab in menu.

3. Click on "Add user".

4. Put any username, email, first name, last name.

5. Click on "Create".

6. After navigation to user page, go to "Credentials" tab.

7. Click on "Set password".

8. Disable "Temporary" flag, set password and repeat password. Click on "Save".

### Create client

1. Select "oidc-app" in realms dropdown.

2. Go to "Clients" tab in menu.

3. Click on "Create client".

4. Client ID: "test-oidc-client".

5. Click on "Next".

6. Enable "Client authentication".

7. Authentication flow: must be only enabled "Standard flow".

8. Valid Redirect URLs:

```
https://localhost:5173/*
```

9. Valid post logout redirect URIs:

```
https://localhost:5173/*
```

9. Web Origins:

```
https://localhost:5173
```

10. Click on "Save".

11. After navigating to client page, go to tab "Credentials".

12. Copy "Client secret" and put it into .env file in backend service in appropriate variable (KEYCLOAK_HTTPS_CLIENT_SECRET).

### Create GitHub OAuth app for example of identity broker mode

1. Go to your GitHub account.

2. Go to "Settings" -> "Developer Settings" -> "OAuth Apps".

3. Click on "New OAuth App".

4. Set any available application name (is not used in the prototype).

5. Set "Homepage URL" as `https://localhost:5173`.

6. Set "Authorization callback URL" as `https://localhost:8443/realms/oidc-app/broker/github/endpoint`.

7. Click on "Register application".

8. After navigation to app page, save "Client ID" and "Client secret" values.

9. Go to Keycloak Admin Console.

10. Select "oidc-app" in realms dropdown.

11. Go to "Identity providers" tab.

12. Click on "GitHub provider".

13. Set "Client ID" and "Client secret" into values saved from GitHub app page.

14. Click on "Add".

### Set session and token lifespan

1. Select "oidc-app" in realms dropdown.

2. Go to "Realms settings".

3. Go to tab "Sessions".

4. Set "SSO Session Idle" into 2 minutes.

    It may be your time, just remember it and pay attention that session idle time must be more than access token lifespan.

5. Go to tab "Tokens".

5. Set "Access Token Lifespan" into 1 minute.

    It may be your time, just remember it and pay attention that access token lifespan must be less than session idle time.

*Test case*

0) Go to "Protcted Page".

1) Login in prototype from Frontend side.

2) Copy access token from cookies into some text file.

3) Wait for `<Access Token Lifespan>`.

4) Refresh page "Protected Page".

5) Copy access token from cookies AGAIN into some text file.

6) Compare it with previous token: they must be different.

7) Wait for `<SSO Session Idle>`.

8) Refresh page "Protected Page". You must be redirected into Keycloak Login Page.
