---
title: New Members
description: Overview for new team members.
---

## Introduction

This document provides information for new members interested in working on either the Groundstation or Telemetry Server components of the Autoboat project. It outlines the necessary skills and knowledge required to effectively contribute to these parts of the codebase, and where to find relevant resources for learning.

The Groundstation lives in the main [`autoboat-vt/autoboat_vt`](https://github.com/autoboat-vt/autoboat_vt) repository under `ground_station/`, and the Telemetry Server is its own repository at [`autoboat-vt/telemetry_server`](https://github.com/autoboat-vt/telemetry_server). Both are written primarily in Python. The Groundstation also embeds a small Vite/TypeScript/Leaflet frontend (the map widget), so a little bit of web knowledge goes a long way.

## Recommended Skills and Knowledge

To work on the Groundstation or Telemetry Server, you should have a solid understanding (_or be willing to learn_) the following:

- **Python Programming**: Both the Groundstation and Telemetry Server are written almost entirely in Python. You should be comfortable with Python syntax, data structures, and libraries. The Telemetry Server uses [Flask](https://flask.palletsprojects.com/en/stable) and [SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/en/stable), while the Groundstation uses [`qtpy`](https://qtpy.readthedocs.io/en/stable/) (a Qt abstraction layer that lets us run on either PySide6 or PyQt without code changes) for its GUI.
- **Qt / PySide6 (via qtpy)**: The Groundstation GUI is built on Qt through `qtpy`. You should _never_ import `PyQt5` or `PyQt6` directly - always go through `qtpy` so the backend stays swappable. You don't need to know the whole Qt API, but you should be familiar with creating windows/widgets, signals and slots, and `QThread`.
- **TypeScript / Vite / Leaflet (Groundstation only)**: The map widget in `ground_station/src/widgets/map_widget/frontend/` is a small [Vite](https://vitejs.dev) + [TypeScript](https://www.typescriptlang.org) app that renders waypoints and buoys on a [Leaflet](https://leafletjs.com) map. You don't need to be a web expert, but basic familiarity with TS, npm/bun, and JS build tooling is useful if you want to touch the map.
- **Networking / HTTP Concepts**: The Groundstation and boat talk to the Telemetry Server over HTTPS REST endpoints (Flask). Understanding basic HTTP methods (GET/POST/DELETE), JSON, and request/response cycles will be helpful, especially when working with the Telemetry Server. See [Telemetry Server API Routes](telemetry_server_api_routes.md) for the full route surface.
- **Multithreading**: Both components use threads. The Groundstation uses `QThread` (see `src/utils/thread_classes.py`) for asynchronous work, and the Telemetry Server uses a read/write lock manager (`lock_manager.py`) to coordinate concurrent requests. A basic understanding of threads and locks in Python will be helpful.
- **Docker / Compose (Telemetry Server only)**: The Telemetry Server is deployed as a multi-service Docker Compose stack (Gunicorn app, Cloudflare tunnel, cron, optional Tailscale). You don't need Docker to develop locally, but it helps to understand the deployment model.

It's hard to be an expert in all of these areas, so don't worry if you are not. The most important thing is to be willing to learn and ask questions when you need help. You will learn much quicker by doing and asking questions when you get stuck than by trying to learn everything beforehand.

## Learning Resources

Here are some resources to help you get started with the necessary skills:

- **Python Programming**:
    - [Official Python Tutorial](https://docs.python.org/3/tutorial/index.html)
    - [Automate the Boring Stuff with Python](https://automatetheboringstuff.com)

- **Qt / PySide6 (via qtpy)**:
    - [PySide6 Documentation](https://doc.qt.io/qtforpython-6/index.html)
    - [PySide6 Tutorials](https://doc.qt.io/qtforpython-6/tutorials/index.html)
    - [qtpy Documentation](https://qtpy.readthedocs.io/en/stable/)

- **TypeScript / Vite / Leaflet (for the map widget)**:
    - [Vite Getting Started](https://vitejs.dev/guide/)
    - [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
    - [Leaflet Quick Start](https://leafletjs.com/SlavaUkraini/quick-start.html)
    - [Bun (the runner we use)](https://bun.sh/docs)

- **Flask / SQLAlchemy (for the Telemetry Server)**:
    - [Flask Quickstart](https://flask.palletsprojects.com/en/stable/quickstart/)
    - [Flask-SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/en/stable/)

- **Networking / HTTP Concepts**:
    - [Python Networking Programming](https://realpython.com/python-sockets/)
    - [Socket Programming in Python](https://docs.python.org/3/library/socket.html)

- **Multithreading in Python**:
    - [Python Threading Module](https://docs.python.org/3/library/threading.html)
    - [Multithreading in Python Tutorial](https://realpython.com/intro-to-python-threading)

- **Docker / Compose (for Telemetry Server deployment)**:
    - [Docker Overview](https://docs.docker.com/get-started/overview/)
    - [Docker Compose](https://docs.docker.com/compose/)

## Getting Help

If you have any questions or need help getting started, please reach out on the Discord server if you are having trouble with anything. The Discord server is great place to get help since we can only meet in person so often. It is also a good place to hang out with other members of the team, discuss ideas, and participate in some team bonding!

## Next Steps

Once you feel comfortable with the necessary skills and have familiarized yourself with the codebase, you can start contributing to the Groundstation and Telemetry Server components. Here are some suggested next steps:

- Clone [`autoboat-vt/autoboat_vt`](https://github.com/autoboat-vt/autoboat_vt) and read through `ground_station/src/` to learn how the Groundstation is structured. You can launch it locally with `cd ground_station && ./run.sh` (after installing [Python](https://www.python.org/downloads) 3.10+ and [Bun](https://bun.sh)).
- Clone [`autoboat-vt/telemetry_server`](https://github.com/autoboat-vt/telemetry_server) and read through `src/autoboat_telemetry_server/` to learn how the Telemetry Server is structured. You can run it locally without Docker using `pip install -e .` then `flask run` (or `gunicorn "autoboat_telemetry_server:create_app()"` for a production-like setup).
- Look for small issues or features that you can work on to get familiar with the codebase and development process.
- Honestly working on the project in any capacity will help you learn faster than anything else, so don't feel like you need to start with something big right away. Just start small and work your way up!
