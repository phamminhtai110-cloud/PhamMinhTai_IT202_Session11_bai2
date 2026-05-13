-- =========================================
-- [BÀI TẬP] LỖ HỔNG NHẬP KHO VẬT TƯ
-- =========================================

USE RikkeiClinicDB;

-- =========================================
-- PHẦN 1: PROCEDURE BỊ LỖI
-- =========================================

DELIMITER //

CREATE PROCEDURE AddInventory(IN p_item_id INT, IN p_quantity INT)
BEGIN

    UPDATE Inventory
    SET stock_quantity = stock_quantity + p_quantity
    WHERE item_id = p_item_id;

END //

DELIMITER ;

-- =========================================
-- PHẦN A: PHÂN TÍCH
-- =========================================

-- Tái hiện lỗi:
-- Nhân viên nhập nhầm số âm -500 cho vật tư item_id = 10

CALL AddInventory(10, -500);

-- Kiểm tra tồn kho sau khi lỗi xảy ra

SELECT *
FROM Inventory
WHERE item_id = 10;

-- =========================================
-- GIẢI THÍCH LỖI
-- =========================================

-- Procedure hiện tại không kiểm tra dữ liệu đầu vào.
-- Khi truyền số âm, phép cộng:
-- stock_quantity = stock_quantity + (-500)
-- sẽ làm giảm tồn kho thay vì nhập thêm hàng.

-- =========================================
-- PHẦN B: SỬA LỖI
-- =========================================

-- Xóa procedure cũ

DROP PROCEDURE IF EXISTS AddInventory;

-- =========================================
-- TẠO LẠI PROCEDURE ĐÚNG
-- =========================================

DELIMITER //

CREATE PROCEDURE AddInventory(IN p_item_id INT, IN p_quantity INT)
BEGIN

    -- Chỉ cho phép nhập số lượng > 0
    IF p_quantity > 0 THEN

        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;

    END IF;

END //

DELIMITER ;

-- =========================================
-- KIỂM THỬ SAU KHI SỬA
-- =========================================

-- Test 1: Nhập hợp lệ

CALL AddInventory(10, 200);

SELECT *
FROM Inventory
WHERE item_id = 10;

-- Kết quả mong muốn:
-- stock_quantity tăng thêm 200

-- =========================================

-- Test 2: Nhập sai số âm

CALL AddInventory(10, -500);

SELECT *
FROM Inventory
WHERE item_id = 10;

-- Kết quả mong muốn:
-- stock_quantity KHÔNG bị giảm

-- =========================================

-- Test 3: Nhập số 0

CALL AddInventory(10, 0);

SELECT *
FROM Inventory
WHERE item_id = 10;

-- Kết quả mong muốn:
-- Không thay đổi dữ liệu