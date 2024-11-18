#!/bin/bash

# Khởi động Docker Compose (chạy ở chế độ nền)
docker-compose up -d

# Chờ một chút để các container khởi động
echo "Đang chờ các container khởi động..."


# Kiểm tra MySQL
echo "MySQL..."
mysql -h 127.0.0.1 -P 3306 -u root -p root1234 -e "SHOW DATABASES;"
mysql -h 127.0.0.1 -P 3306 -u root -p root1234 -e "USE thongdb; SHOW TABLES;"

if [ $? -eq 0 ]; then
  echo "Kết nối MySQL thành công và cơ sở dữ liệu thongdb đã sẵn sàng."
else
  echo "Lỗi khi kết nối MySQL hoặc cơ sở dữ liệu thongdb không tồn tại."
  exit 1
fi

# Kiểm tra Kafka
echo "Kiểm tra Kafka..."
nc -zv localhost 9092
if [ $? -eq 0 ]; then
  echo "Kafka đã sẵn sàng."
else
  echo "Kafka không sẵn sàng."
  exit 1
fi

docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092

# Kiểm tra Kafka Connect
echo "Kiểm tra Kafka Connect..."
curl -s http://localhost:8083/ | grep "Kafka Connect" > /dev/null

if [ $? -eq 0 ]; then
  echo "Kafka Connect đang chạy."
else
  echo "Kafka Connect không sẵn sàng."
  exit 1
fi

curl -s http://localhost:8083/connector-plugins | jq .

# Kiểm tra phpMyAdmin
echo "Kiểm tra phpMyAdmin..."
curl -s http://localhost:8090 | grep "phpMyAdmin" > /dev/null

if [ $? -eq 0 ]; then
  echo "phpMyAdmin có sẵn và hoạt động."
else
  echo "Không thể truy cập phpMyAdmin."
  exit 1
fi

# Kiểm tra Kafdrop
echo "Kiểm tra Kafdrop..."
curl -s http://localhost:9000 | grep "Kafdrop" > /dev/null

if [ $? -eq 0 ]; then
  echo "Kafdrop có sẵn và hoạt động."
else
  echo "Không thể truy cập Kafdrop."
  exit 1
fi

# Dừng và xoá tất cả các container
echo "Dừng và xoá tất cả các container..."
docker-compose down
