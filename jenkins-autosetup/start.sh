#!/bin/bash

AUTOSETUP_TMP=/tmp/autosetup
JENKINS_REF=/usr/share/jenkins/ref/

######################################################################
# Check for a configuration URL for startup
# Can be svn:// or git://
# e.g.
# export AUTOSETUP="svn://<url>/<path> https://github.com/<path>.git"
#
if [ ! -z "$AUTOSETUP" ]; then
    
    for SETUP in ${AUTOSETUP[@]}; do
        if [ -d "$AUTOSETUP_TMP" ]; then
            rm -rf "$AUTOSETUP_TMP"
        fi
        
        EXTS=( ${SETUP:0:3} ${AUTOSETUP:${#SETUP}<3?0:-3} )
        for EXT in ${EXTS[@]}; do
            case $EXT in
                git )
                    git clone --depth=1 --quiet "$SETUP" "$AUTOSETUP_TMP"
                    break
                    ;;
                svn )
                    USER=${SETUP#*//}
                    USER=${USER%@*}
                    
                    if [ ! -z "$USER" ]; then
                        PASSWORD=${USER#*:}
                        USER=${USER%:*}
                        
                        echo "User: $USER"
                        echo "Password: $PASSWORD"
                        svn checkout --username="$USER" --password="$PASSWORD" "$SETUP" "$AUTOSETUP_TMP"
                    else
                        svn checkout "$SETUP" "$AUTOSETUP_TMP"
                    fi
                    
                    break
                    ;;
            esac
        done
        
        # initialise Plugins
        if [ -f "$AUTOSETUP_TMP/plugins.txt" ]; then
            echo "Setting up Plugins - will be loaded on startup using the managePlugins.groovy"
            cp "$AUTOSETUP_TMP/plugins.txt" "${JENKINS_REF}"
        fi
        
        if [ -d "$AUTOSETUP_TMP/config" ]; then
            echo "Copying configuration files"
            find "$AUTOSETUP_TMP/config" -name "*.groovy" -exec cp -v {} "${JENKINS_REF}init.groovy.d/" \;
            find "$AUTOSETUP_TMP/config" -name "*.xml" -exec cp -v {} "${JENKINS_REF}" \;
        fi

        if [ -d "$AUTOSETUP_TMP/jobs" ]; then
            echo "Copying job files"
            find "$AUTOSETUP_TMP/jobs" -name "*.xml" -exec cp -v {} "${JENKINS_REF}jobs/" \;
        fi
    done
    rm -rf "$AUTOSETUP_TMP"
fi

######################################################################

######################################################################
# Modify configuration files with environment variables
#
# Env variable interpolation functions
value_of() {
	eval echo \${$1}
}

interpolate_env() {
	FILE=$1
	for env_var in `cat ${FILE} | grep {| awk -F "{" '{print $2}' | awk -F "}" '{print $1}'`; do
		SUBST=`value_of ${env_var}`
		if [ -n "$SUBST" ]; then
			sed -ie 's|${'"$env_var"'}|'"$SUBST"'|g' $FILE
		fi
	done
}

for FILE in $(find "${JENKINS_REF}" -type f); do
    echo "Interpolating env in file: '${JENKINS_REF}.$FILE'"
    interpolate_env "${JENKINS_REF}.$FILE"
done
######################################################################

/bin/tini -- /usr/local/bin/jenkins.sh $*