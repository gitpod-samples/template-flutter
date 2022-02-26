FROM axonasif/workspace-vnc:latest
SHELL ["/bin/bash", "-c"]

ENV ANDROID_HOME=/home/gitpod/androidsdk \
    FLUTTER_VERSION=2.8.1-stable

# For Qt WebEngine on docker
ENV QTWEBENGINE_DISABLE_SANDBOX 1

# Install Open JDK
USER root
RUN install-packages openjdk-8-jdk -y \
    && update-java-alternatives --set java-1.8.0-openjdk-amd64

# Install ungoogled_chromium
RUN curl -sSL https://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Focal/Release.key | apt-key add - \
  && echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Focal/ /' > /etc/apt/sources.list.d/ungoogled_chromium.list \
  && install-packages ungoogled-chromium

# misc deps
RUN install-packages \
  libasound2-dev \
  libgtk-3-dev \
  libnss3-dev \
  fonts-noto \
  fonts-noto-cjk

# Insall flutter
USER gitpod
RUN wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz" -O - \
    | tar xpJ -C "$HOME" && printf "export PATH=$PATH:%s\n" "$HOME/flutter/bin" > "$HOME/.bashrc"

# Install SDK Manager
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip \
    && mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && unzip commandlinetools-linux-*.zip -d $ANDROID_HOME \
    && rm -f commandlinetools-linux-*.zip \
    && mv $ANDROID_HOME/cmdline-tools/bin $ANDROID_HOME/cmdline-tools/latest \
    && mv $ANDROID_HOME/cmdline-tools/lib $ANDROID_HOME/cmdline-tools/latest

RUN printf '%s\n' 'export ANDROID_HOME=$ANDROID_HOME' \
        'export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH' >> /home/gitpod/.bashrc

# Install Android Image version 30
USER gitpod
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "emulator"
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "system-images;android-30;google_apis;x86_64"
RUN echo no | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n avd28 -k "system-images;android-30;google_apis;x86_64"

RUN flutter/bin/flutter precache

