---
title: Develop Website
description: Develop and test the documentation website.
---

# <p style="text-align: center;">**How to Start Developing on the Website**</p>

Our website is hosted using Virginia Tech's website hosting platform called S4 Web Hosting, which can be found here: [S4 Web Hosting Link](https://4help.vt.edu/sp?id=sc_cat_item&sys_id=229f35ffdbd80700e3a0f839af96193a&pathname=%2Fsp%3Fid%3Dsc_cat_item%26sys_id%3D229f35ffdbd80700e3a0f839af96193a).

Since it is impractical to ask Virginia Tech's S4 Web Hosting team to add someone as a developer every time we want to add someone new to the website, we keep a copy of the website code in our Github organization. This way someone with access to both repositories can clone our repository to their computer and, using Git, set both the Github and S4 Web Hosting repositories to be "remotes" for their local copy of the website code. Then, when we want to push the changes from our Github repository to the S4 Web Hosting repository, we simply push to the S4 Web Hosting remote. This way, we can easily add new developers to the website without needing to ask the S4 Web Hosting team to add them every time.

Mini diagram of the process:  
Your local computer -> Github repository -> S4 Web Hosting repository

## <p style="text-align: center;">Getting Access to the S4 Site</p>

In order to get access to the S4 Site, you need to find someone who already has access to the website and tell them to complete the following steps. (If for any reason you can't contact anyone on the team perhaps because the team has been dormant for some number of years just fill out these steps yourself and hope that the admins allow you to get access to the site)

1. Since we can't directly add someone as a developer, we need to ask the S4 administrators to add them through a help ticket. Please go to the S4 Web Hosting Site found here: [S4 Hosting Site Link](https://4help.vt.edu/sp?id=sc_cat_item&sys_id=229f35ffdbd80700e3a0f839af96193a&pathname=%2Fsp%3Fid%3Dsc_cat_item%26sys_id%3D229f35ffdbd80700e3a0f839af96193a), login into your Virginia Tech account if you are not already logged in. If you are not logged in there should be a red button to the right of your screen that says something like "Login to Request This Service":
   ![alt text](../assets/images/setting_up_website_step1.png)

2. After you have logged in, you should be brought to the following screen with a red button to the right of your screen saying "Request This Service":
   ![alt text](../assets/images/setting_up_website_step2.png)

3. Once you click that button, you should be brought to a help ticket form, which you should fill out with all of the relevant information. Once filled out it should look something like the following:
   ![alt text](../assets/images/setting_up_website_step3.png)

The VT 4help team is usually very responsive and usually will get back to you within a day. Whenever they respond to you, you should receive an email notification, so look out for that.

Once the person trying to get access has been approved, they should be able to access the following site: [https://code.vt.edu/s4-hosting-sites/aoe/sailbot](https://code.vt.edu/s4-hosting-sites/aoe/sailbot). If they can't, that means that something went wrong, but if they can then you should move onto the next step.

## <p style="text-align: center;">Accessing the S4 Site</p>

In order to access the S4 Web Hosting site (aka code.vt.edu), you need to either setup an SSH key or use a personal access token. It is highly recommended that you setup an SSH key, and you may already be required to do this depending on the classes you are taking/taken.

### <p style="text-align: center;">Setting Up an SSH Key</p>

See the following link for instructions on how to set up an SSH key: [SSH Key Setup Link](https://docs.gitlab.com/user/ssh). If this link has changed or is no longer valid, we recommend you search for "How to set up an SSH key on GitLab" and follow the instructions provided by the most reputable source.

### <p style="text-align: center;">Creating a Personal Access Token</p>

If you are unable to set up an SSH key, you can use a personal access token to authenticate yourself. Here are the steps to create a personal access token:

1. From the website, please click on your profile picture in the top left:
   ![alt text](../assets/images/setting_up_website_step4.png)

2. There should be a drop down menu with the button "Edit Profile", so please click on that button.
   ![alt text](../assets/images/setting_up_website_step5.png)

3. Next, click on "Personal Access Tokens" button to the left of the screen.
   ![alt text](../assets/images/setting_up_website_step6.png)

4. Next, click the "Add New Token" button on the top right of the screen.
   ![alt text](../assets/images/setting_up_website_step7.png)

5. Next, enter a name for your token (you can call it whatever you want and it won't matter), and then enter an expiration date (after which time you will have to create another personal access token).
   ![alt text](../assets/images/setting_up_website_step8.png)

6. Next, select all of the "scopes" to allow this personal access token to do anything with your vt gitlab account (If you actually know what you are doing, then you can limit specific scopes but if you don't worry about it too much).
   ![alt text](../assets/images/setting_up_website_step9.png)

7. Once you click the blue "Create Token" button at the button of the screen, then you should be redirected to a screen like this:
   ![alt text](../assets/images/setting_up_website_step10.png)

At the top of the screen, there is a button to copy the newly created personal access token. If you refresh the page, this button will disappear so make sure you copy the personal access token and keep it somewhere on your computer. You will be asked to provide it whenever you have to push code from your computer to the website GitLab.

## <p style="text-align: center;">Git Configuration for Deploy</p>

Run the following commands once on your computer to clone the repo and add the S4 GitLab remote:

```sh
git clone https://github.com/autoboat-vt/website && cd website
git remote add aoe_sites ssh://git@code.vt.edu/s4-hosting-sites/aoe/sailbot
```

(Use the `ssh://` form if you set up an SSH key; if you are using a personal access token instead, use `https://code.vt.edu/s4-hosting-sites/aoe/sailbot` and you will be prompted for your username and token on push.)

### <p style="text-align: center;">Deploying with `scripts/deploy.sh`</p>

Deployments are done with the `scripts/deploy.sh` script. **Do not** push source files directly to `aoe_sites` - the S4 site only serves compiled static assets. The script:

1. Runs `bun run build` (or `npm run build`) to produce a fresh `dist/`.
2. Fetches the latest `aoe_sites/main` into a temporary worktree.
3. Replaces the worktree contents with the new `dist/` output (plus any required top-level files like `.gitlab-ci.yml`).
4. Commits and fast-forward pushes to `aoe_sites/main`.

The S4 service then syncs `main` to the S3 bucket that backs `autoboat.aoe.vt.edu`, usually within a minute.

To deploy:

```sh
./scripts/deploy.sh
```

You still push source changes to GitHub in the normal way:

```sh
git push origin main
```

### <p style="text-align: center;">CI/CD</p>

GitHub Actions runs a **build-only** check on every pull request to confirm the site compiles and tests pass. There is **no automatic deploy from CI** - deployments only happen when a human runs `scripts/deploy.sh` locally. This is intentional: it lets us control exactly when the public site updates.

### <p style="text-align: center;">Pages</p>

The site has the following top-level routes (defined in `src/App.tsx`):

| Route       | Page component     | Purpose                                              |
| ----------- | ------------------ | ---------------------------------------------------- |
| `/`         | `Home`             | Landing page with hero and quick info.               |
| `/ourteam`  | `OurTeam`          | Team member profiles and subteam breakdown.          |
| `/fleet`    | `Fleet`            | Photos and specs of the boats we have built.         |
| `/live`     | `Live`             | Live telemetry map (pulls from the telemetry server).|
| `/sponsors` | `Sponsors`         | Current and past sponsors.                           |
| `/gallery`  | `Gallery`          | Photo and video gallery.                             |
