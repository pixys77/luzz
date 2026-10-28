FROM debian:bookworm-slim
WORKDIR /usr/fuzz/
RUN apt update && apt-get install -y ca-certificates wget curl clang llvm build-essential make cmake git ninja-build lld && rm -rf /var/lib/apt/lists/* 
RUN wget -t 5 https://github.com/openssl/openssl/releases/download/openssl-3.0.16/openssl-3.0.16.tar.gz 
COPY ./start.sh /usr/fuzz
RUN chmod +x start.sh && ./start.sh
RUN rm -rf start.sh
