def add_inventory_item(item, quantity):
    global cur
    cur = None  # Initialize cur
    try:
        # Your logic to add inventory item goes here
        pass
    finally:
        if cur:
            cur.close()  # Check if cur exists before closing


def update_supplier_order(order_id, new_status):
    global cur
    try:
        # Your logic to update supplier order goes here
        pass
    finally:
        cur.close()  # Removed duplicate cur.close() call