#!/usr/bin/env groovy

properties([
    /* Only keep the most recent builds. */
    buildDiscarder(logRotator(numToKeepStr: '20')),
    /* build regularly */
    pipelineTriggers([cron('H H(18-23) * * 4')])
])


node('docker&&linux') {

    stage('Checkout') {
        /* Make sure we're always starting with a fresh workspace */
        deleteDir()
        checkout scm

        def version = sh returnStdout: true, script: './determine-latest-lts.sh'
        version = version.trim()

        /* Checkout the latest LTS release so we don't need to build Jenkins to create the site */
        sh 'git clone https://github.com/jenkinsci/jenkins/ jenkins'
        withEnv([ "version=$version" ]) {
            dir ('jenkins') {
                sh 'git checkout "jenkins-$version"'
            }
        }

        /* We only care about the taglib, so override index page and site descriptor */
        sh 'cp -afv site/ jenkins/core/src'
    }

    stage('Generate') {
        withEnv([
                "PATH+MVN=${tool 'mvn'}/bin",
                "JAVA_HOME=${tool 'jdk11'}",
                "PATH+JAVA=${tool 'jdk11'}/bin"
        ]) {
            dir ('jenkins/core') {
                /* Generate the minimal Maven site */
                sh 'mvn --show-version --batch-mode -DgenerateProjectInfo=false -DgenerateSitemap=false -e clean site:site'
            }
        }
    }

    stage('Archive') {
        dir('jenkins/core/target/site') {
            /* Don't archive additional report files in the top level directory */
            archiveArtifacts artifacts: 'index.html, jelly-taglib-ref.html, *.xsd, */**',
            allowEmptyArchive: false,
            fingerprint: true,
            onlyIfSuccessful: true
        }
    }

    if (infra.isTrusted()) {
        stage ('Publish') {
            dir('jenkins/core/target') {
                sh 'mv -v site core-taglib'
                // This script returns all filepaths separated by the null character (as they can contain white spaces)
                String[] files = sh(returnStdout: true, script: 'find core-taglib -type f -print0').split('\u0000')
                // As the command above returns an array with one empty element if there is no match, check if it's not the case
                if (files[0] != '') {
                    infra.publishReports(files.toList())
                } else {
                    echo 'WARNING: no file found in core-taglib.'
                }
            }
        }
    }
}
