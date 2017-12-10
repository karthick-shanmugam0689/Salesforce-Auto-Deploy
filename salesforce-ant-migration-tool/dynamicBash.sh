#/usr/bin/env bash
# -lcommit builds last commit
# -prevrsa last commit to master
 
#read command line args
while getopts l:p: option
do
        case "${option}"
        in
                l) LCOMMIT=${OPTARG};;
                p) PREVRSA=${OPTARG};;
        esac
done
 
echo Last Commit: $LCOMMIT
echo Previous Commit: $PREVRSA
 
DIRDEPLOY=deploy
if [ -d "$DIRDEPLOY" ]; then
    echo Removing deploy folder
    rm -rf "$DIRDEPLOY"
fi
mkdir -p $DIRDEPLOY
cd src
echo changing directoy to src
cp package.xml{,.bak} &&
echo Backing up package.xml to package.xml.bak
 
read -d '' NEWPKGXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF
echo $NEWPKGXML > package.xml
echo List of changes
echo DIFF: `git diff-tree --no-commit-id --name-only --diff-filter=ACMRTUXB -t -r $PREVRSA $LCOMMIT`
 
git diff-tree --no-commit-id --name-only --diff-filter=ACMRTUXB -t -r $PREVRSA $LCOMMIT | \
while read -r CFILE; do
 
        if [[ $CFILE == *"src/"*"."* ]]
        then
				pattern="salesforce-ant-migration-tool/"
				FINALFILE=${CFILE/$pattern/}
				echo tar filess "../$FINALFILE"
                tar cf - "../$FINALFILE"* | (cd ../$DIRDEPLOY; tar xf -)
        fi
        if [[ $CFILE == *"-meta.xml" ]]
        then
                pattern="salesforce-ant-migration-tool/"
				ADDFILE=${CFILE/$pattern/}
                ADDFILE="${ADDFILE%-meta.xml*}"
                tar cf - ../$ADDFILE | (cd ../$DIRDEPLOY; tar xf -)
        fi
        if [[ $CFILE == *"/aura/"*"."* ]]
        then
				pattern="salesforce-ant-migration-tool/"
				FINALFILE=${CFILE/$pattern/}
                DIR=$(dirname "$FINALFILE")
                tar cf - ../$DIR | (cd ../$DIRDEPLOY; tar xf -)
        fi
 
        case "$CFILE"
        in
                *.snapshot*) TYPENAME="AnalyticSnapshot";;
                *.cls*) TYPENAME="ApexClass";;
                *.component*) TYPENAME="ApexComponent";;
                *.page*) TYPENAME="ApexPage";;
                *.trigger*) TYPENAME="ApexTrigger";;
                *.approvalProcess*) TYPENAME="ApprovalProcess";;
                *.assignmentRules*) TYPENAME="AssignmentRules";;
                */aura/*) TYPENAME="AuraDefinitionBundle";;
                *.autoResponseRules*) TYPENAME="AutoResponseRules";;
                *.community*) TYPENAME="Community";;
                */applications*.app*) TYPENAME="CustomApplication";;
                *.customApplicationComponent*) TYPENAME="CustomApplicationComponent";;
                *.labels*) TYPENAME="CustomLabels";;
                *.md*) TYPENAME="CustomMetadata";;
                */objects/*) TYPENAME="CustomObject";;
                *.objectTranslation*) TYPENAME="CustomObjectTranslation";;
                *.weblink*) TYPENAME="CustomPageWebLink";;
                *.customPermission*) TYPENAME="CustomPermission";;
                *.tab*) TYPENAME="CustomTab";;
                */documents/*.*) TYPENAME="Document";;
                *.email*) TYPENAME="EmailTemplate";;
                */email/*-meta.xml) TYPENAME="EmailTemplate";;
                *.escalationRules*) TYPENAME="EscalationRules";;
                *.globalValueSet*) TYPENAME="GlobalValueSet";;
                *.globalValueSetTranslation*) TYPENAME="GlobalValueSetTranslation";;
                *.group*) TYPENAME="Group";;
                *.homePageComponent*) TYPENAME="HomePageComponent";;
                *.homePageLayout*) TYPENAME="HomePageLayout";;
                *.layout*) TYPENAME="Layout";;
                *.letter*) TYPENAME="Letterhead";;
                *.permissionset*) TYPENAME="PermissionSet";;
                *.cachePartition*) TYPENAME="PlatformCachePartition";;
                *.profile*) TYPENAME="Profile";;
                *.reportType*) TYPENAME="ReportType";;
                *.role*) TYPENAME="Role";;
                *OrgPreference.settings*) TYPENAME="UNKNOWN TYPE";;
                *.settings*) TYPENAME="Settings";;
                */standardValueSets*.standardValueSet*) TYPENAME="StandardValueSet";;
                *.standardValueSetTranslation*) TYPENAME="StandardValueSetTranslation";;
                *.resource*) TYPENAME="StaticResource";;
                *.translation*) TYPENAME="Translations";;
                *.workflow*) TYPENAME="Workflow";;
                *) TYPENAME="UNKNOWN TYPE";;
        esac
 
        if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
        then
 
                case "$CFILE"
                in
                        src/email/*)  ENTITY="${CFILE#src/email/}";;
                        src/documents/*)  ENTITY="${CFILE#src/documents/}";;
                        src/aura/*)  ENTITY="${CFILE#src/aura/}" ENTITY="${ENTITY%/*}";;
                        *) ENTITY=$(basename "$CFILE");;
                esac
 
                if [[ $ENTITY == *"-meta.xml" ]]
                then
                        ENTITY="${ENTITY%%.*}"
                        ENTITY="${ENTITY%-meta*}"
                else
                        ENTITY="${ENTITY%.*}"
                fi
 
                if grep -Fq "<name>$TYPENAME</name>" package.xml
                then
						echo "$TYPENAME" "$ENTITY" sala
                        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
                else
						echo "$TYPENAME" "$ENTITY"
                        xmlstarlet ed -L -s /Package -t elem -n types -v "" package.xml
                        xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" package.xml
                        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
                fi
        fi
done
 
echo Cleaning up Package.xml
xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" package.xml
 
echo ====FINAL PACKAGE.XML=====
cat package.xml
tar cf - package.xml | (cd ../$DIRDEPLOY/src; tar xf -)
