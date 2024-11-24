---Declaração das variáveis---
DECLARE @IDPreenchimento UNIQUEIDENTIFIER;
DECLARE @FichaDadosUnico NVARCHAR(MAX);
DECLARE @FichaDadosArray NVARCHAR(MAX);

---Cursor para iterar sobre o id específico---

DECLARE UpdateCursor CURSOR FOR
SELECT IDPreenchimento, FichaDadosUnico, FichaDadosArray
FROM DadosPreenchimentoFicha
WHERE IDPreenchimento IN (SELECT IDPreenchimento FROM TempIDsParaAtualizacao);

---Abrindo o cursor---

OPEN UpdateCursor;

---Associando os campos do cursor às variáveis---

FETCH NEXT FROM UpdateCursor INTO @IDPreenchimento, @FichaDadosUnico, @FichaDadosArray;

---*Loop através dos registros do cursor---

WHILE @@FETCH_STATUS = 0
BEGIN

   ---Atualização do campo FichaDadosArray com JSON_MODIFY---
   
SET @FichaDadosArray =
        JSON_MODIFY(
            JSON_MODIFY(
                JSON_MODIFY(
                    JSON_MODIFY(
                        JSON_MODIFY(
                            JSON_MODIFY(
                                JSON_MODIFY(
                                    @FichaDadosArray,
                                    '$.AmostraArray.fragmento_kg',
                                    JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$fragmento_g_edt_int') AS FLOAT) / 1000, ']'))
                                ),
                                '$.AmostraArray.pedaço_kg',
                                JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.pedaço_g_edt_int') AS FLOAT) / 1000, ']'))
                            ),
                            '$.AmostraArray.extremidade_kg',
                            JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.extremidade_g_edt_int') AS FLOAT) / 1000, ']'))
                        ),
                        '$.AmostraArray.bloco_kg',
                        JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.bloco_g_edt_int') AS FLOAT) / 1000, ']'))
                    ),
                    '$.AmostraArray.residuo_kg',
                    JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.residuo_g_edt_int') AS FLOAT) / 1000, ']'))
                ),
                '$.AmostraArray.pedaçosmenores_kg',
                JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.pedaçosmenores_g_edt_int') AS FLOAT) / 1000, ']'))
            ),
            '$.AmostraArray.completa_kg',
            JSON_QUERY(CONCAT('[', CAST(JSON_VALUE(@FichaDadosUnico, '$.completa_g_edt_int') AS FLOAT) / 1000, ']'))
        );

    ---Atualizando a tabela com o JSON ajustado---

    UPDATE DadosPreenchimentoFicha
    SET FichaDadosArray = @FichaDadosArray
    WHERE IDPreenchimento = @IDPreenchimento;

   ---Avançando para o próximo registro do cursor---

    FETCH NEXT FROM UpdateCursor INTO @IDPreenchimento, @FichaDadosUnico, @FichaDadosArray;
END;

/*Fechando e liberando o cursor*/

CLOSE UpdateCursor;
DEALLOCATE UpdateCursor;
