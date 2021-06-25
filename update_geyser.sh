#!/usr/bin/env bash
source ~/.zshrc
mvn=true
update_GeyserBlockJavaPlayers=`cd .` # To-Do
update_Floodgate=`cd .` # To-Do
RESET=`tput sgr0`
RED=`tput setaf 1`
BLUE=`tput setaf 4`
PURPLE=`tput setaf 5`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
UNDERLINED=`tput smul`
BOLD=`tput bold`
#
### Config ###
#
geyser_path=~/Geyser ###  !!! VERY IMPORTANT !!! Make sure not to put a slash at the end. This will break build scripts.
geyser_sc=$geyser_path/Geyser ## Must be inside of $geyser_path
floodgate_sc=$geyser_path/Floodgate/ ## Must be inside of $geyser_path
block_java_players=$geyser_path/GeyserBlockJavaPlayers/ ## Must be inside of $geyser_path
output=~/Desktop/Geyser-Build-Output ###  !!! VERY IMPORTANT !!! Make sure not to put a slash at the end.  This will break build scripts.
##############
export JAVA_HOME=`/usr/libexec/java_home -v 16` ; java -version
info(){
    echo "$BLUE$BOLD==>$RESET$BOLD $1$RESET"
}
abort(){
    info "$RED Aborting ..."
    cd
    exit 1
}
switch_jdk(){
        export JAVA_HOME=`/usr/libexec/java_home -v $1` ; java -version
}
no_jdk(){
    info "You either answered 'n' or invalidly. Assuming the answer is 'n'."
    info "Letting Homebrew install their JDK."
}
manual_maven(){
    info "Opening Official links to install maven manually ..."
    info "$RESET (https://maven.apache.org/install.html , https://maven.apache.org/)"
    open https://maven.apache.org/install.html
    open https://maven.apache.org/
    sleep 1s
    info "You can also use this un-official help article: https://blog.netgloo.com/2014/08/14/installing-maven-on-mac-os-x-without-homebrew/"
    open https://blog.netgloo.com/2014/08/14/installing-maven-on-mac-os-x-without-homebrew/

}
###############################
### Maven Captcha
if [[ ! -f /usr/local/bin/mvn ]]; then
    mvn=false
    info "$RED Maven was not found, as this script needs maven to build Geyser and it's related projects."
    info "Do you want for the script to install maven, or would you like to do it yourself ? "
    info "If you chose script, Homebrew (see website brew.sh) will be used to install Maven. "
    info " script/manual "
    read maven
    if [[ $maven = 'script' ]]; then
        info "First, Installing Homebrew so we can install Maven ..."
        if [[ ! -f /usr/local/bin/brew/ ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ ! -f /usr/local/bin/brew ]]; then
                info "$RED Homebrew executable missing, installation definitely failed."
            fi
            echo
            brew --version
            echo
            info "Is Homebrew installed? Read the output above."
            info "(y/n)"
            read  -n 1 brew
            if [[ $brew = 'y' ]]; then
                 info "$GREEN Great! Moving on to Maven Installation."
            else
               info "You answer was invalid or 'n'. Assuming Homebrew Installation$RED Failed$RESET$BOLD. "
                manual_maven
            fi
        else
            info "Detecting your existing Homebrew installation, aborting Homebrew installation. "
        fi
 
        info "Maven Requires The Java Programming Language, or a JDK. "
        info "Homebrew tries to handle this by assuming that a JDK is not installed."
        echo
        java -version
        echo
        info "Is the Java Runtime installed?"
        info "(y/n)"
        read -n 1 jre
        if [[ $jre = 'y' ]]; then
            info "If so, is the version 16 or higher?"
            info "(y/n)"
            read -n 1 java_16
            if [[ $java_16 = 'y' ]]; then
                info "Great!"
                info "Checking to see if javac, Java Compiler Tools are installed."
                javac --version
                info "Is javac Installed ?"
                info "(y/n)"
                read -n 1 javac
                if [[ $javac = 'y' ]]; then
                    info "Great! "
                    info "Will Have Homebrew delete their JDK after Maven is finished installing."
                else
                    no_jdk
                fi
            else
                no_jdk
            fi
        else
            no_jdk
        fi
        echo
        info "Installing Maven ..."
        echo
        brew install maven
        echo
        maven --version
        echo
         if [[ javac  = 'y' ]] && [[ jre = 'y' ]] && [[ java_16 = 'y' ]]; then
            brew uninstall --ignore-dependencies openjdk
        else
            info "Asking for root Permission to link JDK into the system wrappers. "
            sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
            info "Putting Java into your "$"Path ..."
            echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc
            export CPPFLAGS="-I/usr/local/opt/openjdk/include"
            info "$GREEN Great!"
        fi
        echo
        info "Is Maven installed? Check The output above."
        info "(y/n)"
        read -n 1 maven_q
        if [[ $maven_q = 'y' ]]; then
            info "Great!"
        else
            info "You answer was invalid or 'n'. Assuming Maven Installation$RED Failed$RESET$BOLD."
            manual_maven
        fi
       
        switch_jdk 16
        
    elif [[ $maven = 'manual' ]]; then
        info "Detcted that you wish to install maven manually."
        manual_maven
    else
        info "You answer was invalid or 'n'. Assuming that you want to install maven manually."
        manual_maven
    fi
    info "Great!"
    info "Now, re-run this script!"
else
    info "Detected your existing Maven installation."
fi

##### To-Do: Git Captcha

###############################
if [[ ! -e $geyser_path ]]; then
    mkdir $geyser_path
fi
update_Geyser(){
    if [[ ! -e $geyser_sc ]]; then
        cd $geyser_path
        if [[ mvn = 'false' ]]; then
            abort
        fi
        info "Detected that the GeyserMC source code is missing, downloading ..."
        git clone https://github.com/GeyserMC/Geyser.git && cd ./Geyser/ ## At this point, ./Geyser is the same as $geyser_sc
        git checkout master
        git pull
        git submodule update --init --recursive
        if [[ ! -e  ./connector/src/main/resources/languages ]]; then
            info "Source code download failed, or failed to check out submodules of Geyser. Geyser would not build properly if you continued."
            info "Maybe you do not have an internet connection."
            abort
        else
            info "$GREEN Successfully downloaded the source code ! "
        fi
    else 
        info "Detected the existing GeyserMC source code."
        cd $geyser_sc
        git checkout master
        git pull
        git submodule update --init --recursive
        if [[ ! -e  ./connector/src/main/resources/languages ]]; then
            info "Failed to check out submodules of Geyser. Geyser would not build properly if you continued."
            info "Maybe you do not have an internet connection."
            abort
        else
            info "$GREEN Successfully updated to origin/master! "
        fi
    fi
    cd $geyser_sc
    echo
    info "Now building GeyserMC ..."
    echo
    echo
    echo
    mvn clean install
    echo
    echo
    echo
    if [[ ! -e ./Bootstrap/ ]]; then ## Only works on 1st run to detect if build failed, will have to ask how to detect build failure
        info "$RED Build Failed."
        abort
    else
        info "It appears that the build succeeded!" ## Make sure that we are uncertain if it actually suceeds or not
        info "Copying build output to $output ..."
        if [[ ! -e $output ]] || [[ ! -e $output/Geyser/ ]]; then
            mkdir -pv $output/Geyser/
        fi
        cp -fpv ./bootstrap/bungeecord/target/Geyser-Bungeecord.jar $output/Geyser/ && cp -fpv ./bootstrap/spigot/target/Geyser-Spigot.jar $output/Geyser/ && cp -fpv ./bootstrap/sponge/target/Geyser-Sponge.jar $output/Geyser/ && cp -fpv ./bootstrap/standalone/target/Geyser.jar $output/Geyser/ && cp -fpv ./bootstrap/velocity/target/Geyser-Velocity.jar $output/Geyser
        ## Use && so that if 1 copy fails, the following will not run
        ## Therefore, we can use Geyser-Velocity (the last copied file) to detect if all of the copies have succeeded
        if [[ ! -f $output/Geyser/Geyser-Velocity.jar ]]; then
            info "One of the copies$RED failed$RESET$BOLD or the build$RED failed$RESET$BOLD so this script was unable to copy the corresponding file."
            info "Look for files in the target folder in this folder: (popping up)"
            open ./bootstrap/ -a Finder
            abort
        else
            info "Files copied successfully!"
        fi
        info "You should find you build output in $output."
    fi
}



######################################
if [[ ! -e $output ]]; then
    mkdir $output
fi
if [[ $1 = 'geyser' ]]; then
    info "Detected that you just want to run Geyser."
    cd $output
    rm -rf ./old_Geyser/
    mv ./Geyser/ ./old_geyser/
    echo
    update_geyser
else
    info "The 1st argument was not specified or was invalid."
    info "Building all projects."
    cd $output
    rm -rf ./old_Geyser/
    mv ./Geyser/ ./old_geyser/ && mkdir ./Geyser/
    rm -rf ./old_GeyserBlockJavaPlayers/
    mv ./GeyserBlockJavaPlayers/ ./old_GeyserBlockJavaPlayers && mkdir ./GeyserBlockJavaPlayers/
    rm -rf ./old_Floodgate/
    mv ./Floodgate/ ./old_Floodgate/ && mkdir ./Floodgate/
    echo
    update_Geyser
    update_GeyserBlockJavaPlayers
    update_Floodgate
fi

echo
info " $GREEN Have a good day!"
