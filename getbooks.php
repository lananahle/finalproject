<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$username = 'alisaa95_system';
$password = 'Saab1020';
$database = 'alisaa95_system';

$conn = mysqli_connect($host, $username, $password, $database);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$db = $conn;

if (!$db) {
    die("Database connection failed: " . mysqli_connect_error());
}

$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : null;
$genre = isset($_GET['genre']) ? $conn->real_escape_string($_GET['genre']) : null;
$sortBy = isset($_GET['sortBy']) ? $conn->real_escape_string($_GET['sortBy']) : null;

$query = "SELECT * FROM books WHERE 1=1";

if ($search) {
    $query .= " AND (title LIKE '%$search%' OR author LIKE '%$search%' OR description LIKE '%$search%')";
}

if ($genre) {
    $query .= " AND genre = '$genre'";
}

if ($sortBy) {
    $query .= match ($sortBy) {
        'price-asc' => " ORDER BY price ASC",
        'price-desc' => " ORDER BY price DESC",
        'title-asc' => " ORDER BY title ASC",
        'title-desc' => " ORDER BY title DESC",
        default => " ORDER BY id ASC",
    };
}

$result = $conn->query($query);

if (!$result) {
    echo json_encode([
        "status" => "error",
        "message" => "Query failed: {$conn->error}",
        "query" => $query
    ]);
    exit;
}

$books = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $books[] = [
            "id" => (int)$row["id"],
            "title" => $row["title"],
            "author" => $row["author"],
            "genre" => $row["genre"],
            "price" => (float)$row["price"],
            "image_url" => $row["image_url"],
            "description" => $row["description"],
            "stock" => (int)$row["stock"]
        ];
    }
}

echo json_encode([
    "status" => "success",
    "data" => $books,
    "count" => count($books)
]);

$conn->close();
