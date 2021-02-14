FROM ubuntu:latest 
COPY ./ /home/app 
WORKDIR /home/app 
ENV PORT=7498 
CMD ./godot_server