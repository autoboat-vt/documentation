# <p style="text-align: center;"> Adding Documentation </p>

As a team, we want our software and hardware decisions well-documented and kept in one place to ensure that new members can easily learn the big and complex system they work with, as well as quickly be plugged into development process. As such, after achieving a significant milestone, it is highly recommended to document it and contribute to this website. It is a lot easier than it sounds.

To start, install the necessary dependencies. You do not have to do it in docker.

```sh
pip install mkdocs
pip install mkdocs-material
```

!!!NOTE "mac OS Users"
    We can use brew for this.

    ```sh
    brew install mkdocs-material
    ```

Then, clone the github repository:
```sh
git clone https://github.com/autoboat-vt/documentation
```

You may now make changes to the website code. To edit an existing page, simply find its .md file in `docs` and edit the text inside. To add a new page, add the file into whichever folder you want it to be (or create a new folder), type it up, and then include in `mkdocs.yml` under the nav section. The documentation supports html, markdown, and several extensions. <a href="https://facelessuser.github.io/pymdown-extensions">You can read about the extensions here</a>.

To put your changes on the website, run:
```sh
mkdocs build
mkdocs serve
```

This will set the website to run locally on the `http://127.0.0.1:8000/` (localhost) IP address. To access it, just type that link in the web-browser.

After you feel good about your changes, deploy them to the internet:
```sh
mkdocs gh-deploy
```

And don't forget to push them to the github repository!
