import groovy.json.JsonSlurperClassic

nl('docker', [time: 60, time_unit: 'MINUTES', finally: {
    slack.simpleAlert("*Job* #<${env.BUILD_URL}console|`${env.BUILD_NUMBER}`>: build ${env.JOB_NAME.replace('%2F', '/')}")
}]) {

    def paths = [:]
    def images = [:]
    def gitVars, gitTagMap, tag, version, deployTag

    step('Initialize') {
        properties(
                [
                        buildDiscarder(logRotator(artifactDaysToKeepStr: '10', artifactNumToKeepStr: '30', daysToKeepStr: '10', numToKeepStr: '30'))
                ]
        )

        dl.login(env.ID_LOGIN_PASS_REGISTRY)
    }

    step('Checkout') {

        gitVars = checkout([
                $class                           : 'GitSCM',
                branches                         : scm.branches,
                userRemoteConfigs                : scm.userRemoteConfigs,
                doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                extensions                       : [[$class: 'CloneOption', noTags: false, shallow: false, depth: 0, reference: '']],
        ])

        gitTagMap = gl.tag()
        deployTag = "${env.BRANCH_NAME.replace("/", "-").trim()}-${gitVars.GIT_COMMIT.trim()}"
        version = env.BRANCH_NAME == env.DEFAULT_TAG_BRANCH ? env.SERVICE_DEFAULT_TAG.trim() : env.BRANCH_NAME.trim()
        tag = gitTagMap.get('tag')?.trim() && gitTagMap.get('count') == 0 ? gitTagMap.get('tag').trim() : gitVars.GIT_COMMIT.trim()
    }

    step('Build') {
        paths = sh(returnStdout: true, script: "find . -name Dockerfile -type f -exec dirname {} \\;").split()

        for (int i = 0; i < paths.size(); i++) {

            images.putAt(i, docker.build("${env.ID_LOGIN_PASS_REGISTRY}/${env.REGISTRY_NAMESPACE}/nginx-php:${paths[i].substring(2).replace('/', '-')}", " \
                --build-arg ROOTFS_DIR=${paths[i]}/rootfs \
                --build-arg COMMON_ROOTFS_DIR=./common \
                --build-arg VCS_URL=`git config remote.origin.url` \
                --build-arg VCS_REF=`git rev-parse --short HEAD` \
                --build-arg BUILD_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'` \
                --build-arg VERSION=`cat ${paths[i]}/Dockerfile | grep -Eow "^ARG VERSION='.*'" | grep -Po "(?<=')[^']+(?=')"` \
                --pull \
                -f ${paths[i]}/Dockerfile . \
            "))
        }
    }

    step('Push', [retries: 2, last: true]) {
        for (int i = 0; i < images.size(); i++) {
            images[i].push()
        }
    }
}