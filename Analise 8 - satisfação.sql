-- 4. Satisfação por produto/categoria
WITH satisfacao_detalhada AS (
    SELECT 
        c.nome as categoria,
        p.nome as produto,
        COUNT(DISTINCT ip.pedido_id) as total_avaliacoes,
        ROUND(AVG(ip.avaliacao_produto)::numeric, 2) as media_produto,
        COUNT(CASE WHEN ip.avaliacao_produto >= 4 THEN 1 END) as avaliacoes_positivas,
        COUNT(CASE WHEN ip.avaliacao_produto <= 2 THEN 1 END) as avaliacoes_negativas
    FROM categorias c
    LEFT JOIN produtos p ON c.id = p.categoria_id
    LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
    WHERE ip.avaliacao_produto IS NOT NULL
    GROUP BY c.nome, p.nome
)
SELECT 
    categoria,
    ROUND(AVG(media_produto)::numeric, 2) as media_categoria,
    SUM(total_avaliacoes) as total_avaliacoes_categoria,
    ROUND((SUM(avaliacoes_positivas)::numeric / 
        NULLIF(SUM(total_avaliacoes), 0) * 100), 2) as percentual_positivas,
    STRING_AGG(
        CASE 
            WHEN media_produto >= 4 
            THEN produto || ' (' || media_produto || ')'
        END,
        ', '
        ORDER BY media_produto DESC
    ) as melhores_produtos
FROM satisfacao_detalhada
GROUP BY categoria
HAVING SUM(total_avaliacoes) > 0
ORDER BY media_categoria DESC;
