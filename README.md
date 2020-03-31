# ABMI_Shinyproxy
Shinyproxy for interworking with RTROD

## 실행 방법
- Windows 10 환경을 기준으로 작성함.
1. Docker 설치 (https://docs.docker.com/docker-for-windows/install/)

2. ShinyProxy 설정  
- ShinyProxy란 :  https://www.shinyproxy.io/
- ShinyProxy 설정법 : https://www.shinyproxy.io/getting-started/

3. Docker Images 만들기
Shiny Proxy에 올릴 Docker Images를 만드는 방법으로 Dockerfile을 활용해 만듦.

- Directory 구조
```bash
Aegis // ABMI Repo
Gemini // ABMI Repo
SOCRATex // ABMI Repo
icarusViewer // ABMI Repo
nlpSearchTool // ABMI Repo
README.md
application.yml // ShinyProxy 설정 파일
shinyproxy-2.3.0.jar // ShinyProxy 실행 파일
templates // ShinyProxy 템플릿 디렉토리
```

위에서부터 Aegis ~ nlpSearchTool가 ShinyProxy에 올릴 예제 레포지토리

- ABMI Repo 구조 
Ex) Aegis
```bash
Aegis
│  Dockerfile
│  Rprofile.site
│
└─aegis
        app.R
```

Dockerfile 안에 r-base 기반 도커파일이 정의되어 있음

Dockerfile로 Docker image 만들기   
  1. 기반이 되는 이미지 불러오기 
  ```bash
  FROM openanalytics/r-base
  ```
  2. Shiny에 필요한 R 패키지가 의존하는 패키지 설치
  ```bash
  RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0
  ```
  
  3. Shiny에 필요한 패키지들 설치 
  ```
  RUN R -e "install.packages('devtools')"
  ```
  
  4.app.R를 docker image 안에 이동
  ```bash
  RUN mkdir /root/aegis
  COPY aegis /root/aegis

  COPY Rprofile.site /usr/lib/R/etc/
  ```
  
  5. port 열고 ShinyApp 실행
  ```bash
  EXPOSE 3838

  CMD ["R", "-e", "shiny::runApp('/root/aegis')"]
  ```


4. ShinyProxy 설정 파일 수정
```yaml
  proxy: // 다양한 설정들
    title: ABMI Analysis Tools
    template-path: ./templates/2col
    logo-url: http://www.openanalytics.eu/sites/www.openanalytics.eu/themes/oa/logo.png
    landing-page: /
    heartbeat-rate: 10000
    heartbeat-timeout: 60000
    port: 8080
    authentication: simple
    admin-groups: scientists
  # Example: 'simple' authentication configuration
  users: // 유저 설정, 일반 설정 뿐만 아니라 여러 인증 수단이 존재함
  - name: guest
    password: password
    groups: scientists
  - name: jeff
    password: password
    groups: mathematicians
# Docker configuration
  docker:
    cert-path: /home/none
    url: http://localhost:2375
    port-range-start: 20000
  specs: // aegis image의 이름 실행 명령어를 통해 사용자 접속시 Container를 생성해 띄워줌
  - id: aegis
    display-name: AEGIS
    description: Application for Epidemiological Geographic Information System (AEGIS). An open source spatial analysis tool based on CDM
    container-cmd: ["R", "-e", "shiny::runApp('/root/aegis/')"]
    container-image: aegis:v0.1
    access-groups: scientists
```

5. 만들어진 Docker images 활용해 ShinyProxy 실행
```bash
cd <ShinyProxy.2.3.0.jar 가 있는 경로>
java -jar shinyproxy-2.3.0.jar  
```
