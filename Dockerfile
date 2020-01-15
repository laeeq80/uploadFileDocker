	FROM openjdk:11.0-jre-slim 

	### Setup user for build execution and application runtime
	ENV APP_ROOT=/opt/app-root
	ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
	COPY bin/ ${APP_ROOT}/bin/
	
	#Setting env variables
        ENV SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M"
        ENV JAVA_OPTS="-Xms512m -Xmx2g"
	
	#Solving issues with jessi
	RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie-backports.list
        RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
        RUN rm -rf /var/lib/apt/lists/* && apt update

	#Installing Zip
        RUN apt-get update && apt-get install -y unzip zip

	# Moving my distribution to docker image
        COPY ./uploadfile-1.0.zip ${APP_ROOT}/bin
	RUN cd ${APP_ROOT}/bin && unzip ${APP_ROOT}/bin/uploadfile-1.0.zip && chmod u+x ${APP_ROOT}/bin/uploadfile-1.0/bin/uploadfile && rm ${APP_ROOT}/bin/uploadfile-1.0.zip		
	
	RUN chmod -R u+x ${APP_ROOT}/bin && \
    		chgrp -R 0 ${APP_ROOT} && \
    		chmod -R g=u ${APP_ROOT} /etc/passwd

	### Containers should NOT run as root as a good practice
	USER 10001
	WORKDIR ${APP_ROOT}

	### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
	ENTRYPOINT [ "uid_entrypoint" ]
	EXPOSE 9000
	CMD run
