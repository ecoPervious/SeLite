#!/bin/bash
#change dir to where this script is located:
cd "$( dirname "${BASH_SOURCE[0]}" )"
HOME_FOLDER=~

# decrease the version
#sed -i '' -r 's/0\.[0-9]+/0.05/' install.rdf
# uncomment/comment minVersion, compatibleVersion
#sed -i '' -r "s/minVersion: '0\.[0-9]+'/minVersion: '0.05'/" SeLiteExtensionSequencerManifest.js
#echo "<!-- 0.10 -->" | sed  "s/<!--\(.*\)-->/\1/"

# It needs variables 'extension' and 'field'. It accepts an optional variable 'value'. If 'value' is not set, then this comments out the line that has the field. For 'extension' see setup_versions(). This adds ".." around value of $value. It expects SeLiteExtensionSequencerManifest.js to have any commas at the beginning of a line that defines an entry, e.g.: ,minVersion: "0.10".
function change_or_comment_out() {
    local from to    # reset first
    local "${@}"
    if ["$value"]
        # uncomment (if commented out), and change the value
        sed -i '' -r "s/(\/\/)?\(,\s*$field:\)\s*['\"][0-9.]*['\"]/\1 \"$value\"/" extensions/$extension/chrome/content/SeLiteExtensionSequencerManifest.js
    else
        # comment out
        sed -i '' -r "s/(\/\/)?\(,\s*$field:\s*['\"][0-9.]*['\"]\)/\/\/\1/" extensions/$extension/chrome/content/SeLiteExtensionSequencerManifest.js
    fi
}

# (re)set:
# - 'version' in of install.rdf and/or
# - 'minVersion', 'compatibleVersion' and 'oldestCompatibleVersion' in SeLiteExtensionSequencerManifest.js. If any of those are not set, they will be commented out in SeLiteExtensionSequencerManifest.js.
# Pass any of the above quoted words as variables (see calls below).
# Pass variable 'extension', the folder name directly under extensions/ for the extension to be modified (the dependent extension).
# Variables minVersion and compatibleVersion apply to all requisites - therefore use this only with extensions that have max. one direct requisite.
function setup_versions() {
    local from to    # reset first
    local "${@}"
    if [-z "$extension"]
        echo Pass at least parameter/variable extension >/dev/stderr
        exit 1
    fi
    if ["version"]
        # For using sed see also http://sed.sourceforge.net/sedfaq3.html#s3.1.2
        sed -i '' -r "s/<em:version>\([0-9.]+\)</em:version>/<em:version>$version</em:version>/" extensions/$extension/install.rdf
    fi
    
    change_or_comment_out extension=$extension field=minVersion value=$minVersion
    change_or_comment_out extension=$extension field=compatibleVersion value=$compatibleVersion
    change_or_comment_out extension=$extension field=oldestCompatibleVersion value=$oldestCompatibleVersion
}

# It expects one parameter, a file path of the expected output, relative to shell-tests/
function run_against {
    # Firefox Browser Console goes to stdout, not to stderr
    firefox -P SeLiteExtensionSequencerTest -no-remote -chrome chrome://selite-extension-sequencer/content/extensions/checkAndQuit.xul 2>/dev/null | egrep --invert-match 'console.(log|info|warning):' | sort > /tmp/selite.actual-output
    sort $HOME_FOLDER/selite/extension-sequencer/shell-tests/$1 | diff - /tmp/selite.actual-output >/tmp/selite.diff
    if [ -s /tmp/selite.diff ]
    then
        echo "Test $1 failed. Difference between the expected (<) and the actual (>) output:" >/dev/stderr
        cat /tmp/selite.diff >/dev/stderr
    fi
}

# see tests.html
setup_versions extension=train version=0.10
run_against expected_outputs/01_default.txt

#run_against expected_outputs/02_train_minVersion_compatibleVersion.txt