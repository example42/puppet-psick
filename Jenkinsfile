pipeline {
  agent any
  stages {
    stage('Syntax') {
      parallel {
        stage('Syntax') {
          steps {
            sh 'pdk validate puppet,metadata'
          }
        }
      }
    }
    stage('Unit') {
      steps {
        sh 'pdk test unit'
      }
    }
    stage('Documentation') {
      steps {
        sh 'rm -rf doc public .yardoc README.md'
        sh 'bin/docs_classlistgenerate.sh site/profile docs/classes.md'
        sh 'for f in $(cat docs/toc.txt); do cat docs/$f >> README.md ; echo >> README.md ; done'
        sh 'bin/jenkins_before.sh'
        sh 'puppet strings generate **/*.pp **/*.rb **/**/*.pp **/**/*.rb **/**/**/*.pp **/**/**/*.rb'
      }
    }
  }
}
