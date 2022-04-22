FROM gitpod/workspace-full-vnc:2022-04-22-13-51-04
SHELL ["/bin/bash", "-c"]

ENV ANDROID_HOME=$HOME/androidsdk \
    FLUTTER_VERSION=2.10.5-stable \
    QTWEBENGINE_DISABLE_SANDBOX=1
    # For Qt WebEngine on docker

# Install Open JDK
USER root
RUN install-packages openjdk-8-jdk -y \
    && update-java-alternatives --set java-1.8.0-openjdk-amd64
    
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
    | tar xpJ -C "$HOME"
# Install android cli tools
RUN _file_name="commandlinetools-linux-8092744_latest.zip" && wget "https://dl.google.com/android/repository/$_file_name" \
    && unzip "$_file_name" -d $ANDROID_HOME \
    && rm -f "$_file_name" \
    && mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && mv $ANDROID_HOME/cmdline-tools/{bin,lib} $ANDROID_HOME/cmdline-tools/latest

ENV PATH="$HOME/flutter/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH" 

# Install Android Image version 31
USER gitpod
RUN yes | sdkmanager "platform-tools" "platforms;android-31" "emulator" \
    && yes | sdkmanager "system-images;android-31;google_apis;x86_64" \
    && echo no | avdmanager create avd -n avd28 -k "system-images;android-31;google_apis;x86_64"

# Cache flutter registry
RUN flutter precache

