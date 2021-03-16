pipeline {

     agent {
        docker {
          image 'drobovictor/dz11prep'
          //arguments for mapping sockets and user root
          args '-v /var/run/docker.sock:/var/run/docker.sock -u 0:0'
          //authenthication on dockerHUB
          registryCredentialsId 'dfba1886-a8ad-4e5d-8832-137cf45beb1e'
          }
        }

        stages {

          stage('copying wedapp repo') {
             steps {
             //копируем репозиторий с тестовым приложением
             //предварительно подкидываем в него докерфайл для создания продового образа
             git 'https://github.com/Sandenev/boxfusefortest'
             }
          }
          stage('building war file') {
             steps {
                sh 'mvn package'
             }
          }
          stage('build and push docker image to dockerHUB') {
            steps {
              sh 'docker build -f Dockerfile -t drobovictor/fin1 .'
              sh 'docker push drobovictor/fin1'
            }
          }
        }
}