# CI Script

Scripts to deploy with CI to gh-pages.

## Setup

Setup a new repo to deploy to gh-pages on macosx

```shell
# change to your directory
cd /project/root

# generate required folders
mkdir -p ./ci/.ssh

# generate keys with no passphrase
ssh-keygen -t rsa -b 4096 -C "sh@signalwerk.ch" -f ./ci/.ssh/id_rsa

# get the required scripts
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/.drone.yml > .drone.yml
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/.travis.yml > .travis.yml
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/ci/build.sh > ./ci/build.sh
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/ci/gh-pages.sh > ./ci/gh-pages.sh

# encrypt the private key with ssh

# generate the symmetric 256 bit key:
# openssl rand -hex -out secret.key 64
openssl rand -hex 64 | tr -d '\n' > ./ci/.ssh/secret.key


# Encrypt file using key - sha256 set to have openssl 1 & 2 compatibility
openssl aes-256-cbc -md sha256 -in ./ci/.ssh/id_rsa -out ./ci/.ssh/id_rsa.enc -pass file:./ci/.ssh/secret.key

# copy key to clipboard
cat ./ci/.ssh/secret.key | pbcopy

# Add GH_PAGES_KEY secret
printf "Add secret from \033[0;31mclipboard\033[0m with label \033[0;31mGH_PAGES_KEY\033[0m to CI.\n"

# delete symmetric key
# rm -f secret.key

# ignore private key for git !!!
# make sure there is a .gitignore
touch .gitignore
echo 'ci/.ssh/id_rsa' >> .gitignore
echo 'ci/.ssh/secret.key' >> .gitignore

# add all the files
git add -A ./ci/.ssh/id_rsa.enc
git add -A ./ci/.ssh/id_rsa.pub
git add -A ./.drone.yml
git add -A ./.travis.yml
git add -A ./ci/build.sh
git add -A ./ci/gh-pages.sh
git add -A ./.gitignore

git commit -m "ADD: build system for CI"

# install deploy key
# -----------------------------------------------------------------------------
# add deploy key to https://github.com/<user>/<repo>/settings/keys
cat ./ci/.ssh/id_rsa.pub | pbcopy

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
curl https://raw.githubusercontent.com/signalwerk/drone-ci/master/ci/lftp.sh > ./ci/lftp.sh
```


```diff

steps:
+ - name: deploy-ftp
+   image: signalwerk/lftp:latest
+   commands:
+     - bash ./ci/lftp.sh pull
+   environment:
+     FTP_SERVER: myServer
+     FTP_USER: myUser
+     FTP_PASSWORD: myPassword
+     FTP_LOCAL_DIR: ./myLocal
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
