<?php
// Conexão
$conn = new mysqli("localhost", "root", "", "aulaapp");
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao conectar"]);
    exit;
}
$conn->set_charset("utf8");

// Utilidades
function json($data, $code = 200) {
    http_response_code($code);
    header("Content-Type: application/json");
    echo json_encode($data);
    exit;
}
function validar($d) {
    return empty($d['nome']) || empty($d['telefone']);
}

// Roteamento
$m = $_SERVER['REQUEST_METHOD'];
$uri = explode('/', trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/'));
$script = basename(__FILE__); // clientes.php
$index = array_search($script, $uri);
$id = isset($uri[$index + 1]) ? $uri[$index + 1] : null;
$body = json_decode(file_get_contents("php://input"), true);
$desde = $_GET['desde'] ?? null;

// Operações
if ($m === 'GET') {
    if ($id) {
        $campo = is_numeric($id) ? "id" : "uuid";
        $stmt = $conn->prepare("SELECT * FROM clientes WHERE $campo = ? AND is_deleted = 0");
        $stmt->bind_param("s", $id);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        $res ? json($res) : json(["erro" => "Cliente não encontrado"], 404);
    } else {
        if ($desde) {
            $stmt = $conn->prepare("SELECT * FROM clientes WHERE is_deleted = 0 AND (created_at >= ? OR updated_at >= ?)");
            $stmt->bind_param("ss", $desde, $desde);
        } else {
            $stmt = $conn->prepare("SELECT * FROM clientes WHERE is_deleted = 0");
        }
        $stmt->execute();
        $res = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        json($res);
    }
}

if ($m === 'POST') {
    if (validar($body)) json(["erro" => "Nome e telefone obrigatórios"], 400);
    $uuid = $body['uuid'] ?? uniqid("", true);
    $stmt = $conn->prepare("INSERT INTO clientes (uuid, nome, telefone) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $uuid, $body['nome'], $body['telefone']);
    $stmt->execute();
    $id = $conn->insert_id;
    $res = $conn->query("SELECT * FROM clientes WHERE id = $id")->fetch_assoc();
    json($res, 201);
}

if ($m === 'PUT' && $id) {
    if (validar($body)) json(["erro" => "Nome e telefone obrigatórios"], 400);
    $campo = is_numeric($id) ? "id" : "uuid";
    $stmt = $conn->prepare("UPDATE clientes SET nome = ?, telefone = ?, updated_at = NOW() WHERE $campo = ? AND is_deleted = 0");
    $stmt->bind_param("sss", $body['nome'], $body['telefone'], $id);
    $stmt->execute();
    $res = $conn->query("SELECT * FROM clientes WHERE $campo = '$id'")->fetch_assoc();
    json($res);
}

if ($m === 'DELETE' && $id) {
    $campo = is_numeric($id) ? "id" : "uuid";
    $conn->query("UPDATE clientes SET is_deleted = 1 WHERE $campo = '$id'");
    json(["mensagem" => "Cliente excluído"]);
}

// Método inválido
json(["erro" => "Método não permitido"], 405);
