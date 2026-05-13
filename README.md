# PhamMinhTai_IT202_Session11_bai2

# BÁO CÁO PHÂN TÍCH HỆ THỐNG

## Bài 2 - Lỗ hổng Nhập kho vật tư

---

# 1. Mô tả bài toán

Tại hệ thống quản lý Phòng khám, bộ phận kho sử dụng chức năng nhập vật tư y tế để cộng thêm số lượng tồn kho mỗi khi nhận hàng mới.

Hệ thống sử dụng Stored Procedure `AddInventory` để cập nhật tồn kho.

Quy tắc nghiệp vụ:

* Số lượng nhập kho phải lớn hơn 0.
* Không cho phép nhập số âm.
* Không cho phép dữ liệu làm giảm tồn kho thông qua chức năng nhập hàng.

Tuy nhiên, hệ thống hiện tại chưa kiểm tra dữ liệu đầu vào.

Khi nhân viên nhập nhầm số âm, hệ thống không báo lỗi mà lại trực tiếp trừ vào tồn kho hiện tại.

Điều này gây:

* Sai lệch số lượng vật tư
* Thất thoát dữ liệu kho
* Ảnh hưởng kiểm kê
* Mất tính chính xác của hệ thống quản lý vật tư

---

# 2. Phân tích nguyên nhân lỗi

## 2.1 Stored Procedure hiện tại

```sql
DELIMITER //

CREATE PROCEDURE AddInventory(
    IN p_item_id INT,
    IN p_quantity INT
)
BEGIN

    UPDATE Inventory
    SET stock_quantity = stock_quantity + p_quantity
    WHERE item_id = p_item_id;

END //

DELIMITER ;
```

---

## 2.2 Vấn đề logic

Procedure trên thực hiện phép cộng:

```sql
stock_quantity = stock_quantity + p_quantity
```

Nếu:

```sql
p_quantity = -500
```

Thì hệ thống sẽ thực hiện:

```sql
stock_quantity = stock_quantity - 500
```

Kết quả:

* Chức năng nhập kho lại làm giảm hàng tồn.
* Hệ thống không phát hiện dữ liệu bất thường.

---

# 3. Tái hiện lỗi hệ thống

## 3.1 Kiểm tra dữ liệu ban đầu

```sql
SELECT *
FROM Inventory
WHERE item_id = 10;
```

Ví dụ:

| item_id | item_name           | stock_quantity |
| ------- | ------------------- | -------------- |
| 10      | Khau trang y te N95 | 1000           |

---

## 3.2 Nhân viên nhập nhầm số âm

```sql
CALL AddInventory(10, -500);
```

---

## 3.3 Kiểm tra kết quả

```sql
SELECT *
FROM Inventory
WHERE item_id = 10;
```

### Kết quả lỗi

| item_id | stock_quantity |
| ------- | -------------- |
| 10      | 500            |

Tồn kho bị giảm từ 1000 xuống 500.

---

# 4. Hướng xử lý

## 4.1 Ý tưởng sửa lỗi

Procedure cần kiểm tra:

```sql
p_quantity > 0
```

Chỉ cho phép cập nhật kho khi dữ liệu hợp lệ.

Nếu:

* `p_quantity <= 0`

→ Không thực hiện UPDATE.

---

# 5. Xóa Procedure cũ

```sql
DROP PROCEDURE IF EXISTS AddInventory;
```

---

# 6. Procedure đã sửa logic

```sql
DELIMITER //

CREATE PROCEDURE AddInventory(
    IN p_item_id INT,
    IN p_quantity INT
)
BEGIN

    IF p_quantity > 0 THEN

        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;

    END IF;

END //

DELIMITER ;
```

---

# 7. Giải thích phiên bản đã sửa

## Logic hoạt động

Procedure mới sẽ:

1. Kiểm tra dữ liệu nhập kho
2. Chỉ cho phép nhập nếu số lượng > 0
3. Nếu dữ liệu âm hoặc bằng 0:

   * Không cập nhật database
   * Không làm thay đổi tồn kho

Điều này giúp:

* Bảo vệ dữ liệu kho
* Ngăn thất thoát vật tư
* Đảm bảo đúng nghiệp vụ nhập hàng

---

# 8. Kiểm thử hệ thống

## 8.1 Test nhập hợp lệ

### Input

```sql
CALL AddInventory(10, 100);
```

### Kết quả mong muốn

| stock_quantity |
| -------------- |
| 1100           |

---

## 8.2 Test nhập số âm

### Input

```sql
CALL AddInventory(10, -500);
```

### Kết quả mong muốn

| stock_quantity |
| -------------- |
| Không thay đổi |

Hệ thống chặn dữ liệu sai.

---

## 8.3 Test nhập bằng 0

### Input

```sql
C
```
