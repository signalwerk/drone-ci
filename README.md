# Drone CI

Scripts to deploy with Drone CI to gh-pages.

## Setup

Setup a new repo to deploy to gh-pages on macosx

```shell
# change to your directory
cd /project/root

# generate required folders
mkdir -p ./drone/.ssh

# generate keys with no passphrase
ssh-keygen -t rsa -b 4096 -C "sh@signalwerk.ch" -f ./drone/.ssh/id_rsa

# get the required scripts
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/.drone.yml > .drone.yml
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/drone/build.sh > ./drone/build.sh
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/drone/gh-pages.sh > ./drone/gh-pages.sh

# encrypt the private key with ssh

# generate the symmetric 256 bit key:
# openssl rand -hex -out secret.key 64
openssl rand -hex 64 | tr -d '\n' > ./drone/.ssh/secret.key


# Encrypt file using key - md5 set to have openssl 1 & 2 compatibility
openssl aes-256-cbc -md md5 -in ./drone/.ssh/id_rsa -out ./drone/.ssh/id_rsa.enc -pass file:./drone/.ssh/secret.key

# copy key to clipboard
cat ./drone/.ssh/secret.key | pbcopy

# Add GH_PAGES_KEY secret
printf "Add secret from \033[0;31mclipboard\033[0m with label \033[0;31mGH_PAGES_KEY\033[0m to drone.\n"

# delete symmetric key
# rm -f secret.key

# ignore private key for git !!!
# make sure there is a .gitignore
touch .gitignore
echo 'drone/.ssh/id_rsa' >> .gitignore
echo 'drone/.ssh/secret.key' >> .gitignore

# add all the files
git add -A ./drone/.ssh/id_rsa.enc
git add -A ./drone/.ssh/id_rsa.pub
git add -A ./.drone.yml
git add -A ./drone/build.sh
git add -A ./drone/gh-pages.sh
git add -A ./.gitignore

git commit -m "ADD: build system for Drone CI"

# install deploy key
# -----------------------------------------------------------------------------
# add deploy key to https://github.com/<user>/<repo>/settings/keys
cat ./drone/.ssh/id_rsa.pub | pbcopy

```

## Additional config

Configure branches

```diff
    ...
    environment:
      ...
+     SOURCE_BRANCH: "master"
+     TARGET_BRANCH: "gh-pages"
```

Init submodules

```diff

steps:
+ - name: submodules
+   image: docker:git
+   commands:
+     - git submodule update --init --recursive --remote

  - name: build
    ...
```

## Deploy to FTP

```shell
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/drone/lftp.sh > ./drone/lftp.sh
```


```diff

steps:
+ - name: deploy-ftp
+   image: signalwerk/lftp:latest
+   commands:
+     - bash ./drone/lftp.sh pull
+   environment:
+     FTP_SERVER: myServer
+     FTP_USER: myUser
+     FTP_PASSWORD: myPassword
+     FTP_LOCAL_DIR: /myLocal
+     FTP_REMOTE_DIR: /myRemote
+   when:
+     branch:
+       - master

  - name: build
    ...
```

### Thanks for inspiration

* https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
* https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example
