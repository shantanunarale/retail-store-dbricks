import sys
import os
import json
import uuid
import time
import faker as f
from datetime import datetime
import random

full_path = os.path.join("/Volumes/retail_store_dev/landing/retail_store", "orders")
os.makedirs(full_path, exist_ok=True)
fake = f.Faker("en_In")

p_id = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
while True:
    current = datetime.now()
    file_path = full_path + "/order_" + current.strftime("%Y-%m-%d_%H-%M-%S") + ".json"
    orders = []        
    for i in range(random.randint(1, 10)):
        line_items = []
        for i in range(random.randint(1, 10)):
            line_items.append({"product_id": random.choice(p_id), "quantity": random.randint(1, 10)})                
        
        orders.append(
            {
                "order_id": str(uuid.uuid4()),
                "order_date": datetime.now().isoformat(),
                "customer_name": fake.name(),
                "customer_address": fake.address(),
                "employee_id" : random.randint(1, 20),
                "order_amount": round(random.random() * 1000, 2),
                "line_items": line_items
            }
        )    
    print(f"Writing file {file_path} - {len(orders)} records")
    with open(file_path, "w") as f:
        json.dump(orders, f)

    time.sleep(5)