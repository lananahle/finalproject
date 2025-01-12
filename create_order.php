<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

require_once 'db_connection.php';

$jsonData = file_get_contents('php://input');
$orderData = json_decode($jsonData, true);

if (!$orderData || !isset($orderData['payment_method']) || !isset($orderData['address']) || 
    !isset($orderData['phone']) || !isset($orderData['total_amount']) || !isset($orderData['items'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid or missing data']);
    exit();
}

try {
    $conn->begin_transaction();

    $stmt = $conn->prepare("INSERT INTO orders (payment_method, delivery_address, phone, total_amount, status) VALUES (?, ?, ?, ?, 'pending')");
    
    if (!$stmt) {
        throw new Exception("Failed to prepare order statement: " . $conn->error);
    }

    $stmt->bind_param("sssd", 
        $orderData['payment_method'],
        $orderData['address'],
        $orderData['phone'],
        $orderData['total_amount']
    );

    if (!$stmt->execute()) {
        throw new Exception("Failed to insert order: " . $stmt->error);
    }

    $orderId = $conn->insert_id;

    $stmtItems = $conn->prepare("INSERT INTO order_items (order_id, book_id, quantity, price) VALUES (?, ?, ?, ?)");
    
    if (!$stmtItems) {
        throw new Exception("Failed to prepare order items statement: " . $conn->error);
    }

    foreach ($orderData['items'] as $item) {
        $checkStock = $conn->prepare("SELECT stock FROM books WHERE id = ?");
        $checkStock->bind_param("i", $item['book_id']);
        $checkStock->execute();
        $result = $checkStock->get_result();
        $currentStock = $result->fetch_assoc()['stock'];

        if ($currentStock < $item['quantity']) {
            throw new Exception("Insufficient stock for book ID: " . $item['book_id']);
        }

        $stmtItems->bind_param("iiid",
            $orderId,
            $item['book_id'],
            $item['quantity'],
            $item['price']
        );

        if (!$stmtItems->execute()) {
            throw new Exception("Failed to insert order item: " . $stmtItems->error);
        }

        $updateStmt = $conn->prepare("UPDATE books SET stock = stock - ? WHERE id = ?");
        $updateStmt->bind_param("ii", $item['quantity'], $item['book_id']);
        
        if (!$updateStmt->execute()) {
            throw new Exception("Failed to update stock: " . $updateStmt->error);
        }
    }

    if ($orderData['payment_method'] === 'card' && isset($orderData['card_details'])) {
        $stmtCard = $conn->prepare("INSERT INTO payment_details (order_id, card_number, expiry, cvv) VALUES (?, ?, ?, ?)");
        $stmtCard->bind_param("isss",
            $orderId,
            $orderData['card_details']['number'],
            $orderData['card_details']['expiry'],
            $orderData['card_details']['cvv']
        );
        
        if (!$stmtCard->execute()) {
            throw new Exception("Failed to store card details: " . $stmtCard->error);
        }
    }

    $conn->commit();
    
    http_response_code(200);
    echo json_encode([
        'success' => true, 
        'order_id' => $orderId,
        'message' => 'Order placed successfully'
    ]);

} catch (Exception $e) {
    $conn->rollback();
    
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => $e->getMessage(),
        'error_details' => $conn->error ?? 'No additional details'
    ]);
}

$conn->close();
