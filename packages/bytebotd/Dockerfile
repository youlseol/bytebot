# -----------------------------------------------------------------------------
# Bytebot Dockerfile - Virtual Desktop Environment
# -----------------------------------------------------------------------------

# Base image
FROM ubuntu:22.04

# -----------------------------------------------------------------------------
# 1. Environment setup
# -----------------------------------------------------------------------------
# Set non-interactive installation
ARG DEBIAN_FRONTEND=noninteractive
# Configure display for X11 applications
ENV DISPLAY=:0

# -----------------------------------------------------------------------------
# 2. System dependencies installation
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    # X11 / VNC
    xvfb x11vnc xauth x11-xserver-utils \
    x11-apps sudo software-properties-common \
    # Desktop environment 
    xfce4 xfce4-goodies dbus wmctrl \
    # Display manager with autologin capability
    lightdm \
    # Development tools
    python3 python3-pip curl wget git vim \
    # Utilities
    supervisor netcat-openbsd \
    # Applications
    xpdf gedit xpaint \
    # Libraries
    libxtst-dev \
    # Remove unneeded dependencies
    && apt-get remove -y light-locker xfce4-screensaver xfce4-power-manager || true \
    # Clean up to reduce image size
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/dbus && \
    # Generate a machine-id so dbus-daemon doesn't complain
    dbus-uuidgen --ensure=/etc/machine-id

# -----------------------------------------------------------------------------
# 3. Additional software installation
# -----------------------------------------------------------------------------
# Install Firefox
RUN apt-get update && apt-get install -y \
    # Install necessary for adding PPA
    software-properties-common apt-transport-https wget gnupg \
    # Install Additional Graphics Libraries
    mesa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    # Install Sandbox Capabilities
    libcap2-bin \
    # Install Fonts
    fontconfig \
    fonts-dejavu \
    fonts-liberation \
    fonts-freefont-ttf \
    && add-apt-repository -y ppa:mozillateam/ppa \
    && apt-get update \
    && apt-get install -y firefox-esr thunderbird \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    # Set Firefox as default browser system-wide
    && update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 200 \
    && update-alternatives --set x-www-browser /usr/bin/firefox-esr \
    && fc-cache -f -v

# Install Google Chrome (amd64) or Chromium (arm64)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        # Install Google Chrome for AMD64
        echo "Installing Google Chrome for AMD64 architecture..." && \
        wget -qO /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
        apt-get update && apt-get install -y /tmp/google-chrome.deb && \
        rm -f /tmp/google-chrome.deb && \
        google-chrome --version && \
        apt-get clean && rm -rf /var/lib/apt/lists/*; \
    elif [ "$ARCH" = "arm64" ]; then \
        # Install Chromium for ARM64 using Playwright's pre-built binary
        echo "Installing Chromium for ARM64 architecture..." && \
        apt-get update && apt-get install -y wget unzip libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
            libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
            libgbm1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 libxshmfence1 && \
        # Download Chromium from Playwright builds (ARM64 compatible)
        mkdir -p /opt/chromium && \
        wget -O /tmp/chromium.zip "https://playwright.azureedge.net/builds/chromium/1148/chromium-linux-arm64.zip" && \
        cd /opt/chromium && unzip /tmp/chromium.zip && \
        mv chrome-linux/* . && rmdir chrome-linux && \
        # Create wrapper script
        echo '#!/bin/bash' > /usr/bin/chromium && \
        echo 'exec /opt/chromium/chrome --no-sandbox --disable-dev-shm-usage --disable-gpu "$@"' >> /usr/bin/chromium && \
        chmod +x /usr/bin/chromium && \
        ln -sf /usr/bin/chromium /usr/bin/google-chrome && \
        # Create desktop file
        mkdir -p /usr/share/applications && \
        echo '[Desktop Entry]' > /usr/share/applications/chromium.desktop && \
        echo 'Version=1.0' >> /usr/share/applications/chromium.desktop && \
        echo 'Name=Chromium Web Browser' >> /usr/share/applications/chromium.desktop && \
        echo 'GenericName=Web Browser' >> /usr/share/applications/chromium.desktop && \
        echo 'Comment=Access the Internet' >> /usr/share/applications/chromium.desktop && \
        echo 'Exec=/usr/bin/chromium %U' >> /usr/share/applications/chromium.desktop && \
        echo 'Terminal=false' >> /usr/share/applications/chromium.desktop && \
        echo 'Type=Application' >> /usr/share/applications/chromium.desktop && \
        echo 'Icon=/opt/chromium/product_logo_256.png' >> /usr/share/applications/chromium.desktop && \
        echo 'Categories=Network;WebBrowser;' >> /usr/share/applications/chromium.desktop && \
        echo 'MimeType=text/html;text/xml;application/xhtml+xml;' >> /usr/share/applications/chromium.desktop && \
        echo 'StartupNotify=true' >> /usr/share/applications/chromium.desktop && \
        # Cleanup
        rm -rf /tmp/chromium.zip && \
        apt-get clean && rm -rf /var/lib/apt/lists/* && \
        echo "Chromium installed successfully"; \
    else \
        echo "Chrome/Chromium is not available for $ARCH architecture."; \
    fi


# Install 1Password based on architecture
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        # Install from APT repository for AMD64
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | \
        tee /etc/apt/sources.list.d/1password.list && \
        mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
        mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
        apt-get update && apt-get install -y 1password && \
        apt-get clean && rm -rf /var/lib/apt/lists/*; \
    elif [ "$ARCH" = "arm64" ]; then \
        # Install from tar.gz for ARM64
        apt-get update && apt-get install -y \
            libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils \
            libatspi2.0-0 libdrm2 libgbm1 libxcb-dri3-0 libxkbcommon0 \
            libsecret-1-0 && \
        apt-get clean && rm -rf /var/lib/apt/lists/* && \
        curl -sSL https://downloads.1password.com/linux/tar/beta/aarch64/1password-latest.tar.gz -o /tmp/1password.tar.gz && \
        # Extract the full 1Password bundle so libraries like libffmpeg.so remain in their expected relative paths
        mkdir -p /opt/1password && \
        tar -xzf /tmp/1password.tar.gz -C /opt/1password --strip-components=1 && \
        # Link the main executable into the global PATH
        ln -sf /opt/1password/1password /usr/bin/1password && \
        chmod +x /opt/1password/1password && \
        # Copy icons to standard locations
        mkdir -p /usr/share/pixmaps /usr/share/icons/hicolor/512x512/apps /usr/share/icons/hicolor/256x256/apps && \
        find /opt/1password -name "*1password*.png" -o -name "*1password*.svg" | while read icon; do \
            if [[ "$icon" == *"512"* ]]; then \
                cp "$icon" /usr/share/icons/hicolor/512x512/apps/1password.png 2>/dev/null || true; \
            elif [[ "$icon" == *"256"* ]]; then \
                cp "$icon" /usr/share/icons/hicolor/256x256/apps/1password.png 2>/dev/null || true; \
            fi; \
            cp "$icon" /usr/share/pixmaps/1password.png 2>/dev/null || true; \
        done && \
        # Clean up temporary files
        rm -rf /tmp/1password.tar.gz && \
        # Update icon cache
        gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true; \
    else \
        echo "1Password is not available for $ARCH architecture."; \
    fi

# Install Visual Studio Code
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        apt-get update && apt-get install -y wget gpg apt-transport-https software-properties-common && \
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/ms_vscode.gpg && \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms_vscode.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
        apt-get update && apt-get install -y code && \
        apt-get clean && rm -rf /var/lib/apt/lists/* ; \
    elif [ "$ARCH" = "arm64" ]; then \
        apt-get update && apt-get install -y wget gpg && \
        wget -qO /tmp/code_arm64.deb https://update.code.visualstudio.com/latest/linux-deb-arm64/stable && \
        apt-get install -y /tmp/code_arm64.deb && \
        rm -f /tmp/code_arm64.deb && \
        apt-get clean && rm -rf /var/lib/apt/lists/* ; \
    else \
        echo "VSCode is not available for $ARCH architecture."; \
    fi

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# -----------------------------------------------------------------------------
# 4. VNC and remote access setup
# -----------------------------------------------------------------------------
# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/websockify \
    && cd /opt/websockify \
    && pip3 install --break-system-packages .

# -----------------------------------------------------------------------------
# 5. Application setup (bytebotd)
# -----------------------------------------------------------------------------
# Copy package files first to leverage Docker cache

# Install dependencies required to build libnut-core and uiohook-napi
RUN apt-get update && \
    apt-get install -y \
        cmake \
        libx11-dev \
        libxtst-dev \
        libxinerama-dev \
        libxi-dev \
        libxt-dev \
        libxrandr-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        xclip \
        git build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY ./shared/ /bytebot/shared/
COPY ./bytebotd/ /bytebot/bytebotd/
WORKDIR /bytebot/bytebotd
RUN npm install --build-from-source
RUN npm rebuild uiohook-napi --build-from-source

RUN npm run build

WORKDIR /compile

RUN git clone https://github.com/ZachJW34/libnut-core.git && \
    cd libnut-core && \
    npm install && \
    npm run build:release

# replace /bytebotd/node_modules/@nut-tree-fork/libnut-linux/build/Release/libnut.node with /compile/libnut-core/build/Release/libnut.node
RUN rm -f /bytebot/bytebotd/node_modules/@nut-tree-fork/libnut-linux/build/Release/libnut.node && \
    cp /compile/libnut-core/build/Release/libnut.node /bytebot/bytebotd/node_modules/@nut-tree-fork/libnut-linux/build/Release/libnut.node

RUN rm -rf /compile

WORKDIR /bytebot/bytebotd

# -----------------------------------------------------------------------------
# 7. User setup and autologin configuration
# -----------------------------------------------------------------------------
# Create non-root user
RUN useradd -ms /bin/bash user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /var/run/dbus && \
    chmod 755 /var/run/dbus && \
    chown user:user /var/run/dbus

RUN mkdir -p /tmp/bytebot-screenshots && \
    chown -R user:user /tmp/bytebot-screenshots

# -----------------------------------------------------------------------------
#  Copy staged system files and keep sane permissions
# -----------------------------------------------------------------------------
# 1. Ensure everything under /bytebotd/root is owned by root (files + dirs)
# 2. Set *files* to 0644 and *directories* to 0755 so that applications can
#    traverse directories (execute bit!) while keeping the contents read-only.
# 3. Copy the tree to /
RUN chown -R root:root /bytebot/bytebotd/root && \
    find /bytebot/bytebotd/root -type f -exec chmod 644 {} + && \
    find /bytebot/bytebotd/root -type d -exec chmod 755 {} + && \
    find /bytebot/bytebotd/root -type f -executable -exec chmod +x {} + && \
    cp -a /bytebot/bytebotd/root/. /

RUN chown -R user:user /home/user
RUN chmod -R 755 /home/user

RUN mkdir -p /home/user/Desktop && \
    for desktop_file in \
        firefox.desktop \
        google-chrome.desktop \
        chromium-browser.desktop \
        chromium.desktop \
        thunderbird.desktop \
        1password.desktop \
        code.desktop \
        terminal.desktop; do \
      if [ -f /usr/share/applications/"$desktop_file" ]; then \
        cp -f /usr/share/applications/"$desktop_file" /home/user/Desktop/; \
      fi; \
    done && \
    chmod +x /home/user/Desktop/*.desktop && \
    chown user:user /home/user/Desktop/*.desktop

RUN mkdir -p /home/user/.config /home/user/.local/share /home/user/.cache \
    && chown -R user:user /home/user/.config /home/user/.local /home/user/.cache

WORKDIR /home/user

# -----------------------------------------------------------------------------
# 8. Port configuration and runtime
# -----------------------------------------------------------------------------
# - Port 9990: bytebotd and external noVNC websocket
EXPOSE 9990

# Start supervisor to manage all services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-n"]
