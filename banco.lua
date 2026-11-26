-- Variavel que guarda a conexao com o banco
banco = nil

addEventHandler('onResourceStart', resourceRoot, function()
    -- Abre (ou cria) o arquivo do banco
    banco = dbConnect('sqlite', 'dados.db')

    if not banco then
        outputServerLog('Erro: nao consegui conectar no banco!')
        return
    end

    -- Cria a tabela de contas, se ainda nao existir
    dbExec(banco, [[
        CREATE TABLE IF NOT EXISTS contas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT UNIQUE,
            senha TEXT,
            dinheiro INTEGER DEFAULT 1000
        )
    ]])

    outputServerLog('Banco de dados pronto!')
end)

addCommandHandler('registrar', function(jogador, comando, usuario, senha)
    -- 1. confere se digitou usuario e senha
    if not usuario or not senha then 
        outputChatBox('use: /registrar usuario senha', jogador, 255, 0, 0)
        return
    end

    -- 2. confere se o usuario ja existe 
    local consulta = dbQuery(banco, 'SELECT id FROM contas WHERE usuario = ?', usuario)
    local resultado = dbPoll(consulta, -1)

    if #resultado > 0 then
        outputChatBox('Esse usuario ja existe!', jogador, 255, 0, 0)
        return
    end

    -- 3. gera o hash da senha salva
    local hash = passwordHash(senha,'bcrypt', {})
    dbExec(banco, 'INSERT INTO contas (usuario, senha) VALUES (?, ?)', usuario, hash)

    outputChatBox('Conta criada! agora use /login ' .. usuario .. 'sua senha', jogador, 255, 0, 0)
end)