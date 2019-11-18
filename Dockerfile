FROM azul/zulu-openjdk:8u192

COPY ./corda-4.3.jar /app/corda.jar

WORKDIR /app

CMD java -jar corda.jar
