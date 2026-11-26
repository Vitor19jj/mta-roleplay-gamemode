-- Lugar onde o jogador vai nascer
local spawnX, spawnY, spawnZ = 1959.55, -1714.46, 17
local logados = {}

-- Funcao que faz o jogador nascer
function nascer(jogador)
    if not isElement(jogador) then return end

    spawnPlayer (jogador, spawnX, spawnY, spawnZ, 0, 0, 0, 0)
    fadeCamera(jogador, true)
    setCameraTarget(jogador, jogador)
    setElementHealth(jogador, 100)
    outputChatBox('Bem-vindo a los santos, ' .. getPlayerName(jogador) .. '!', jogador, 0, 255, 0)
end

-- Quando o jogador morre, renasce depois de 3 segundos
addEventHandler('onPlayerWasted', root, function()
    local jogador = source
    if logados[jogador] then
    setTimer(nascer, 3000, 1, jogador)
    end
end)

-- comando /kill
addCommandHandler('kill', function(jogador)
    if isPedDead(jogador) then
        outputChatBox('Voce ja esta morto!', jogador, 255, 0, 0)
        return
    end
    killPed(jogador)
end)

-- comando /vida
addCommandHandler('vida', function(jogador)
    setElementHealth(jogador, 100)
    outputChatBox('Sua vida foi preenchida!', jogador, 0, 0, 0)
end)

addCommandHandler('resetcontas', function(jogador)
    --so o console do servidor pode usar 
    if getElementsType(jogador) ~= 'console' then
        outputChatBox('Sem permissao!', jogador, 0, 0, 0)
        return
    end

    dbExec(banco, 'DELETE FROM contas')
    dbExec(banco, "DELETE FROM sqlite_sequence WHERE name = 'contas'")
    outputServerLog('Todas as contas foram apagadas!')
end)

addCommandHandler('entrar', function(jogador, comando, usuario, senha)
    -- 1. Ja esta logado?
    if logados [jogador] then
        outputChatBox('Voce ja esta logado!', jogador, 255, 0, 0)
        nascer(jogador)
        return
    end

    -- 2. Digitou tudo?
    if not usuario or not senha then
        outputChatBox('use: /login usuario senha', jogador, 255, 0, 0)
        return
    end

    -- 3. Busca conta
    local consulta = dbQuery(banco, 'SELECT id, senha FROM contas WHERE usuario = ? ', usuario)
    local resultado = dbPoll(consulta, -1)

    if #resultado == 0 then 
        outputChatBox('Usuario ou senha incorretos!', jogador, 255, 0, 0)
        return
    end

    -- 4. confere a senha com hash 
    local conta = resultado [1]
    if not passwordVerify(senha, conta.senha) then
        outputChatBox('Usuario ou senha incorreto!', jogador, 255, 0, 0)
        return
    end
    
    -- 5. Deu certo: marca como logado
    logados[jogador] = conta.id
    outputChatBox('Login feito! Bem-vindo, ' .. usuario .. '!', jogador, 0, 255, 0)
end)

-- Quando o jogador sai, remove da tabela 
addEventHandler('onPlayerQuit', root, function()
    logados[source] = nill
end)