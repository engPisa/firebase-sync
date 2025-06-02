from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)
DATABASE = 'contacts.db'

# Função para inicializar o banco e criar a tabela
def init_db():
    with sqlite3.connect(DATABASE) as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                phone TEXT NOT NULL,
                synced INTEGER DEFAULT 0,
                isDeleted INTEGER DEFAULT 0
            )
        ''')
    print('📚 Banco de dados inicializado!')

# Função para conectar no banco
def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# Rota para adicionar um contato (POST)
@app.route('/save', methods=['POST'])
def add_contact():
    data = request.get_json()

    name = data.get('name')
    phone = data.get('phone')

    if not name or not phone:
        return jsonify({'success': False, 'message': 'Dados inválidos'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO contacts (name, phone, synced, isDeleted) VALUES (?, ?, 1, 0)',
        (name, phone)
    )
    conn.commit()
    conn.close()

    return jsonify({'success': True, 'message': 'Contato criado com sucesso.'}), 201

# Rota para listar todos os contatos (GET)
@app.route('/contatos', methods=['GET'])
def get_contacts():
    conn = get_db_connection()
    contacts = conn.execute('SELECT * FROM contacts WHERE isDeleted = 0').fetchall()
    conn.close()

    return jsonify([dict(contact) for contact in contacts])

# Rota para deletar um contato logicamente (PUT)
@app.route('/contato/<int:id>', methods=['PUT'])
def delete_contact(id):
    conn = get_db_connection()
    conn.execute('UPDATE contacts SET isDeleted = 1 WHERE id = ?', (id,))
    conn.commit()
    conn.close()
    return jsonify({'success': True, 'message': 'Contato deletado logicamente.'})

# Inicializa o banco antes de rodar
if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=8000, debug=True)
