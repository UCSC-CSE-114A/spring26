---
layout: page
title: Setting up for CSE114A
permalink: /setup/
---

This guide will help you with getting set up and ready for the assignments in this course.

## Autograder Setup

In this class you will be using the autograder client to submit your assignments. To use the autograder, you will first have to install it. The autograder requires that you have Python installed, and you should use a Python virtual environment when using the autograder. 

The instructions here do not go into much detail. If you want a much more in-depth explanation of virtual environments, etc., the [CSE40 Hands-On 0 readme](https://github.com/ucsc-cse-40/HO0) is perfect for that, although the actual autograder usage differs slightly, so you will want to refer to this document for CSE114A specifics. 

### Python

To check if you have Python installed, you can run the following command at the command line. The autograder requires that you have at least Python version 3.8 installed. 

```sh
python3 -V
```

If you do not have Python installed, you can go [here](https://wiki.python.org/moin/BeginnersGuide/Download) and follow the instructions to install it. 

### Virtual Environment

Once you have Python installed, you need to create a virtual environment. 

For organizational purposes, the best thing to do first is creating a new directory for all your CSE114A-related files. You can do this via the command line using the following command (in this case we are naming the new directory "cse114a").

```sh
mkdir cse114a
```

Then, you can go into that directory using this command:

```sh
cd cse114a
```

Once you have done that, you can create your virtual environment (or "venv" for short) by running the following command. In this case, we have named our virtual environment "cse114a_venv", but you can name it however you want. 

```sh
python3 -m venv cse114a_venv
```

When you are submitting assignments for this course, you should make sure to have your venv active. However, at no point do you create any repos or files within the venv directory (e.g., don't `cd` into `cse114a_venv` and then clone your repos there). To activate your virtual enviroment, on Linux, MacOS, or any POSIX system, you can run this command, assuming you are in the directory that contains your venv directory:

```sh
source cse114a_venv/bin/activate
```

If you are using Windows, you may instead have to use this command:

```sh
.\cse114a_venv\Scripts\activate
```

When your virtual environment is active, your command prompt should look something like this:

```sh
(cse114a_venv) hostname:directory $ 
```

To deactivate your virtual environment, simply run the command:

```sh
deactivate
```

### Autograder Installation

Now that you have your virtual environment set up, you can install the autograder client. If you have used the autograder for another class, you may not need to install it again, but if not, you can run this command:

```sh
pip3 install autograder-py
```

### Autograder Commands

The following are commands that you should be familiar with when using the autograder:

- `autograder.run.submit` submits your code to the autograder
- `autograder.run.history` shows you a history of all your submissions 
- `autograder.run.peek` will show you your latest submission

To view the full list of autograder commands that you can use, simply type:

```sh
python3 -m autograder.run
```

Whenever you use the autograder for submission or checking history, you will need to provide the user, password, and course name. Also, you should make sure you are in the correct directory of your repo when running these commands. For example, if you are submitting the assignment `00-lambda`, you should make sure you are in the top level directory for that assignment. If the name of your assignment repository is `00-lambda-sammyslug`, your prompt should look something like this:

```sh
(cse114a_venv) hostname:00-lambda-sammyslug $
```

The command you run to submit the `00-lambda` assignment will be:

```sh
python3 -m autograder.run.submit INTEGRITY.md tests/* --user <email> --pass <password> --course <course>
```

where

- `<email>` is your UCSC email address;
- `<pass>` is your autograder password (not your UCSC Blue or Gold password -- your autograder password is specific to the autograder, and you should receive an email with your own password);
and 
- `<course>` is an identifier specific to this course and section, which you can find on the Canvas assignment description for this assignment.

Running this command will submit your code to the autograder for evaluation and print out the results. Have patience -- it might take a minute or two to see output from the autograder. You can submit as many times as you like before the deadline, and only the last submission will be counted. 

The [autograder client documentation](https://github.com/edulinq/autograder-py/blob/main/README.md#commands-for-students) has more information about the autograder if you are curious. 

## SSH Keys and Cloning Assignment Repos

### SSH Key Generation

If you already have SSH keys set up for your GitHub account, you can skip this. 

(Thanks to Eriq Augustine for this information on SSH keys, which was taken from CSE40!)

When using git, the easiest way to authenticate (login) from the command line is to use [SSH keys](https://wiki.archlinux.org/title/SSH_keys).
SSH keys are a pair of keys (a private key and a public key) that you can generate to let other people/programs/servers know who you are.
You want to make sure to always keep your private key **private** and never give it to anyone else.
You can share your public key with anyone who wants to authenticate you (like Github).
Github essentially requires that you use SSH keys when working with private repositories
(you can technically use [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-personal-access-token-classic),
but those are not recommended for this course).

By default, SSH keys live in your `~/.ssh` directory (where `~` means your [home directory](https://en.wikipedia.org/wiki/Home_directory).
You can look in there for any existing SSH keys that you have (and skip the next step if you want).
By default, keys start with the `id_` prefix.
Public keys will have the `.pub` suffix, while private keys will have no suffix.

To generate SSH keys, we use the `ssh-keygen` command.
There are various options that you can use to change the security on the key generated,
but the default settings are good enough for this class.
`ssh-keygen` will ask you two questions:
 - Where you want the new key to be placed.
   - If this is your first key, then the default location is fine.
     If this is not your first key, then you should choose some other name that you can remember (in this example, we will use `id_github`).
 - If you want to use a password for your key.
   - This is an additional level of security that you can have, so that every time you use the key it asks for a password.
     A good rule of thumb is that if you are using a machine that is secure and only you use, then you don't need a password.

#### To create and use ssh keys, follow these steps.

First, generate the key.

```sh
ssh-keygen
```

When you run this command, you will see the questions stated above. If this is not your first ssh key, type a new name (such as id_github). If it is, then you can just press enter. 
Then it will ask for password. As mentioned above, you can skip this step (press enter) if your machine is secure and only used by you. 

Now that you have generated your private and public key, you need to copy the **public** key over to github. Again, make sure you do not share your private key anywhere or with anyone. To copy the public key, run:

```sh
cat id_github.pub
```

*Make sure to replace id_github.pub with whatever your key is named, followed by **.pub**. If this is your first key, it is likely id_rsa.pub. You can type ```ls``` in your ```~/.ssh``` directory to check this.*

Note that the keys typically start with `ssh-` and end with a name or email. Copy the whole thing.

Now go into the "SSH and GPG keys" section of your Github settings: https://github.com/settings/keys .
Click the green "New SSH key" button.
Give your key a name and paste the contents of your key into the "Key" section.
Click the "Add SSH key" button and you should be all set!
Now you can use Github in the terminal without needing a password.

### Cloning Repositories

To work on assignments for this class, you will need to clone your private assignment repos onto your machine. In order to do that, first navigate to the GitHub page for your private repo. Then, you can click on the green "Code" button on the right, and using the SSH option, copy the URL. It should look something like this:

```sh
git@github.com:ORGANIZATION/repo_name.git
```

At the command line, inside your cse114a directory (assuming you created one as suggested above), run the following command:

```sh
git clone git@github.com:ORGANIZATION/repo_name.git
```

This will create a local copy of the assignment. Within this directory is where you will work on that particular assignment, and where you will run the autograder. You should become familiar with git commands if you are not already, as you will also need to push your code to git when you are submitting assignments. 

If for some reason you get an error message, verify that your SSH keys have been set up properly, and that you have access to GitHub. A quick web search should help with this, and if you are not able to solve the issue, you can come to office hours for assistance. GitHub also has [very detailed documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) on the topic.

## Finishing up

Now that you have the autograder set up and know how to clone assignments from git, you should be ready to go. Make sure you follow the [Haskell setup instructions on the course website](../materials/) for developing with Haskell and testing your homework assignments before you submit to the autograder. 

Good luck!
