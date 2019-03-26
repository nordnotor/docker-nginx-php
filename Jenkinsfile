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

//        withCredentials([file(credentialsId: env.REGISTRY_ACCESS_CRED, variable: 'file')]) {
//            sh("cat ${file} | docker login -u _json_key --password-stdin https://${REGISTRY_HOST}/${env.REGISTRY_NAMESPACE}")
//        }
//        app = docker.image("${env.REGISTRY_HOST}/${env.REGISTRY_NAMESPACE}/${env.SERVICE_NAME}:${env.SERVICE_DEFAULT_TAG}")
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

            println("${paths[i]}")
            println("${paths[i].substring(2).replace('/', '-')}")

            images.putAt(i, docker.build("${env.ID_LOGIN_PASS_REGISTRY}/${env.REGISTRY_NAMESPACE}/${libGit.repoName()}:${paths.getAt(i).substring(2).replace('/', '-')}", " \
                        --label git.commit=`git rev-parse HEAD` \
                        --label build=${env.BUILD_NUMBER} \
                        --pull --build-arg ROOTFS_DIR=${paths[i]}/rootfs \
                        --build-arg COMMON_ROOTFS_DIR=./common \
                        -f ${paths[i]} . \
                       "))
        }

//        for (int i = 0; i < paths.size(); i++) {
//            images[i] = docker.build(
//                "${env.ID_LOGIN_PASS_REGISTRY}/${env.REGISTRY_NAMESPACE}/${libGit.repoName()}:${paths[i].substring(2).replace('/', '-')}",
//                "--label git.commit=`git rev-parse HEAD` --label build=${env.BUILD_NUMBER} ${paths[i]} "-f ${dockerfile} ./dockerfiles""
//            )
//        }
    }

//    step('Push', [retries: 2, last: true]) {

//        for (int i = 0; i < images.size(); i++) {
//            images[i].push()
//        }
//    }
}