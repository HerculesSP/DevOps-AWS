DROP DATABASE IF EXISTS stockflow;

CREATE DATABASE stockflow
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE stockflow;

SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

CREATE TABLE cargos (
                        id INT NOT NULL AUTO_INCREMENT,
                        nome VARCHAR(255) NOT NULL,
                        descricao VARCHAR(255) DEFAULT NULL,
                        criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO cargos (
    id,
    nome,
    descricao,
    criado_em
) VALUES (
             1,
             'Administrador',
             'Cargo com acesso total ao sistema',
             '2026-04-14 00:51:33'
         );

CREATE TABLE permissoes (
                            id INT NOT NULL AUTO_INCREMENT,
                            nome VARCHAR(255) NOT NULL,
                            descricao VARCHAR(255) NOT NULL,
                            PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO permissoes (
    id,
    nome,
    descricao
) VALUES
      (1, 'GERENCIAR_USUARIOS', 'Permite gerenciar usuarios do sistema'),
      (2, 'GERENCIAR_CARGOS', 'Permite gerenciar cargos do sistema'),
      (3, 'CADASTRAR_ITENS', 'Permite cadastrar novos itens no estoque'),
      (4, 'EDITAR_ITENS', 'Permite editar itens do estoque'),
      (5, 'EXCLUIR_ITENS', 'Permite excluir ou inativar itens do estoque'),
      (6, 'REGISTRAR_ENTRADA', 'Permite registrar entradas de estoque'),
      (7, 'REGISTRAR_SAIDA', 'Permite registrar saidas de estoque'),
      (8, 'VER_RELATORIOS', 'Permite visualizar relatorios do sistema'),
      (9, 'GERENCIAR_ORCAMENTOS', 'Permite gerenciar clientes e orcamentos'),
      (10, 'GERENCIAR_ENCOMENDAS', 'Permite gerenciar encomendas');

CREATE TABLE cargo_permissoes (
                                  cargo_id INT NOT NULL,
                                  permissao_id INT NOT NULL,
                                  PRIMARY KEY (cargo_id, permissao_id),
                                  KEY fk_cargo_permissoes_permissao (permissao_id),
                                  CONSTRAINT fk_cargo_permissoes_cargo
                                      FOREIGN KEY (cargo_id)
                                          REFERENCES cargos (id),
                                  CONSTRAINT fk_cargo_permissoes_permissao
                                      FOREIGN KEY (permissao_id)
                                          REFERENCES permissoes (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO cargo_permissoes (
    cargo_id,
    permissao_id
) VALUES
      (1, 1),
      (1, 2),
      (1, 3),
      (1, 4),
      (1, 5),
      (1, 6),
      (1, 7),
      (1, 8),
      (1, 9),
      (1, 10);

CREATE TABLE unidades (
                          id INT NOT NULL AUTO_INCREMENT,
                          nome VARCHAR(255) NOT NULL,
                          abreviacao VARCHAR(255) DEFAULT NULL,
                          PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO unidades (
    id,
    nome,
    abreviacao
) VALUES
      (1, 'Unidade', 'UN'),
      (2, 'Par', 'PR'),
      (3, 'Metro', 'M');

CREATE TABLE categorias (
                            id INT NOT NULL AUTO_INCREMENT,
                            nome VARCHAR(255) NOT NULL,
                            criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO categorias (
    id,
    nome,
    criado_em
) VALUES
      (1, 'Som Automotivo', '2026-06-08 00:17:33'),
      (2, 'Baterias', '2026-06-08 00:17:33'),
      (3, 'Cabos e Conectores', '2026-06-08 00:17:33'),
      (4, 'Iluminacao', '2026-06-08 00:17:33'),
      (5, 'Materiais de capa', '2026-06-08 00:17:33'),
      (6, 'Acessorios eletricos', '2026-06-08 00:17:33'),
      (7, 'Outros', '2026-06-08 00:17:33');

CREATE TABLE usuarios (
                          id INT NOT NULL AUTO_INCREMENT,
                          cargo_id INT NOT NULL,
                          nome VARCHAR(255) NOT NULL,
                          email VARCHAR(255) NOT NULL,
                          senha_hash VARCHAR(2000),
                          ativo TINYINT(1) NOT NULL DEFAULT '1',
                          ultimo_acesso DATETIME DEFAULT NULL,
                          criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (id),
                          UNIQUE KEY uk_usuarios_email (email),
                          KEY fk_usuarios_cargo (cargo_id),
                          CONSTRAINT fk_usuarios_cargo
                              FOREIGN KEY (cargo_id)
                                  REFERENCES cargos (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO usuarios (
    id,
    cargo_id,
    nome,
    email,
    senha_hash,
    ativo,
    ultimo_acesso,
    criado_em
) VALUES (
             1,
             1,
             'ADM',
             'adm@email.com',
             '$2a$10$FsYqdmjvhmmXTShZNqhGt.g8HHniASRM49aw5FP0GKKD1T0T4Rlkq',
             1,
             '2026-04-14 00:58:47',
             '2026-04-14 00:51:41'
         ), (2,1,'Cleiton Rodrigues','cleiton@email.com','$2a$10$m73IvNciHb/.qXoKA5ChA.aCQ62HXCPazzkB7ZGXkeybDQfTgiChW',1,NULL,'2026-09-14 23:35:03');

CREATE TABLE refresh_tokens (
                                id BIGINT NOT NULL AUTO_INCREMENT,
                                token_hash VARCHAR(100) NOT NULL,
                                expira_em TIMESTAMP NOT NULL,
                                revogado_em TIMESTAMP NULL,
                                usuario_id INT NOT NULL,
                                PRIMARY KEY (id),
                                KEY idx_refresh_token_usuario (usuario_id),
                                KEY idx_refresh_token_expira_em (expira_em),
                                CONSTRAINT fk_refresh_tokens_usuario
                                    FOREIGN KEY (usuario_id)
                                        REFERENCES usuarios(id)
                                        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE itens (
                       id INT NOT NULL AUTO_INCREMENT,
                       categoria_id INT NOT NULL,
                       unidade_id INT NOT NULL,
                       nome VARCHAR(255) NOT NULL,
                       quantidade_atual INT NOT NULL DEFAULT '0',
                       quantidade_minima INT NOT NULL DEFAULT '0',
                       preco_custo DOUBLE DEFAULT NULL,
                       preco_venda DOUBLE DEFAULT NULL,
                       ativo TINYINT(1) NOT NULL DEFAULT '1',
                       criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                           ON UPDATE CURRENT_TIMESTAMP,
                       PRIMARY KEY (id),
                       KEY fk_itens_categoria (categoria_id),
                       KEY fk_itens_unidade (unidade_id),
                       CONSTRAINT fk_itens_categoria
                           FOREIGN KEY (categoria_id)
                               REFERENCES categorias (id),
                       CONSTRAINT fk_itens_unidade
                           FOREIGN KEY (unidade_id)
                               REFERENCES unidades (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimentacoes (
                               id INT NOT NULL AUTO_INCREMENT,
                               item_id INT NOT NULL,
                               usuario_id INT NOT NULL,
                               tipo VARCHAR(20) NOT NULL,
                               quantidade INT NOT NULL,
                               estoque_antes INT NOT NULL,
                               estoque_depois INT NOT NULL,
                               data DATE NOT NULL,
                               observacao VARCHAR(255) DEFAULT NULL,
                               criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               PRIMARY KEY (id),
                               KEY fk_movimentacoes_item (item_id),
                               KEY fk_movimentacoes_usuario (usuario_id),
                               CONSTRAINT fk_movimentacoes_item
                                   FOREIGN KEY (item_id)
                                       REFERENCES itens (id),
                               CONSTRAINT fk_movimentacoes_usuario
                                   FOREIGN KEY (usuario_id)
                                       REFERENCES usuarios (id),
                               CONSTRAINT chk_movimentacoes_tipo
                                   CHECK (tipo IN ('entrada', 'saida'))
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE arquivos (
                          id INT NOT NULL AUTO_INCREMENT,
                          item_id INT DEFAULT NULL,
                          movimentacao_id INT DEFAULT NULL,
                          tipo_arquivo VARCHAR(20) NOT NULL,
                          uri VARCHAR(500) DEFAULT NULL,
                          nome VARCHAR(255) DEFAULT NULL,
                          mime_type VARCHAR(100) DEFAULT NULL,
                          tamanho INT DEFAULT NULL,
                          criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (id),
                          KEY idx_arquivos_item (item_id),
                          KEY idx_arquivos_movimentacao (movimentacao_id),
                          CONSTRAINT fk_arquivos_item
                              FOREIGN KEY (item_id)
                                  REFERENCES itens (id)
                                  ON DELETE CASCADE,
                          CONSTRAINT fk_arquivos_movimentacao
                              FOREIGN KEY (movimentacao_id)
                                  REFERENCES movimentacoes (id)
                                  ON DELETE CASCADE,
                          CONSTRAINT chk_arquivos_origem
                              CHECK (
                                  (
                                      item_id IS NOT NULL
                                          AND movimentacao_id IS NULL
                                      )
                                      OR
                                  (
                                      item_id IS NULL
                                          AND movimentacao_id IS NOT NULL
                                      )
                                  ),
                          CONSTRAINT chk_arquivos_tipo
                              CHECK (
                                  tipo_arquivo IN ('imagem', 'nota_entrada')
                                  )
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alertas (
                         id INT NOT NULL AUTO_INCREMENT,
                         item_id INT NOT NULL,
                         tipo VARCHAR(30) NOT NULL,
                         visualizado TINYINT(1) NOT NULL DEFAULT '0',
                         criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         PRIMARY KEY (id),
                         KEY fk_alertas_item (item_id),
                         CONSTRAINT fk_alertas_item
                             FOREIGN KEY (item_id)
                                 REFERENCES itens (id),
                         CONSTRAINT chk_alertas_tipo
                             CHECK (tipo IN ('estoque_baixo', 'zerado'))
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO itens (
    id,
    categoria_id,
    unidade_id,
    nome,
    quantidade_atual,
    quantidade_minima,
    preco_custo,
    preco_venda,
    ativo
) VALUES
      (1, 1, 1, 'Rádio Bluetooth 1 DIN', 8, 3, 185.00, 299.90, 1),
      (2, 1, 1, 'Central Multimídia 7 Polegadas', 5, 2, 620.00, 899.90, 1),
      (3, 1, 1, 'Alto-falante Triaxial 6 Polegadas', 14, 6, 78.00, 129.90, 1),
      (4, 1, 1, 'Subwoofer Automotivo 12 Polegadas', 3, 2, 410.00, 599.90, 1),
      (5, 2, 1, 'Bateria Automotiva 60 Ah', 7, 3, 425.00, 579.90, 1),
      (6, 2, 1, 'Bateria Automotiva 70 Ah', 4, 2, 510.00, 689.90, 1),
      (7, 2, 1, 'Bateria de Moto 7 Ah', 2, 3, 82.00, 129.90, 1),
      (8, 3, 1, 'Cabo RCA 5 Metros', 18, 8, 18.00, 34.90, 1),
      (9, 3, 1, 'Cabo para Alto-falante 2 x 1,5 mm', 45, 15, 4.50, 9.90, 1),
      (10, 3, 1, 'Cabo de Alimentação 10 mm', 22, 8, 12.00, 24.90, 1),
      (11, 3, 1, 'Conector ISO para Rádio', 11, 5, 14.00, 29.90, 1),
      (12, 4, 1, 'Lâmpada LED H4', 16, 6, 38.00, 69.90, 1),
      (13, 4, 1, 'Lâmpada LED H7', 4, 5, 42.00, 74.90, 1),
      (14, 4, 1, 'Kit Barra LED 12 V', 9, 3, 55.00, 99.90, 1),
      (15, 5, 1, 'Capa de Banco Automotivo Universal', 6, 3, 95.00, 159.90, 1),
      (16, 5, 1, 'Capa de Volante em Couro Sintético', 13, 5, 22.00, 44.90, 1),
      (17, 5, 1, 'Capa para Alavanca de Câmbio', 1, 2, 18.00, 39.90, 1),
      (18, 6, 1, 'Fusível Lâmina 10 A', 38, 15, 1.20, 3.50, 1),
      (19, 6, 1, 'Relé Automotivo 12 V', 12, 5, 9.00, 19.90, 1),
      (20, 6, 1, 'Suporte de Fusíveis', 3, 3, 16.00, 32.90, 1),
      (21, 7, 2, 'Kit Abraçadeiras Plásticas', 20, 8, 6.00, 14.90, 1);

INSERT INTO arquivos VALUES 
    (1,1,NULL,'imagem','imagens/8f4afc36-1b58-4fc4-96b7-d83ec2b69824.jpeg','radio-bluetooth.jpeg','image/jpeg',22419,'2026-09-14 11:36:22'),
    (2,2,NULL,'imagem','imagens/b5c65c79-a933-4ee7-9e6a-e1bb30984aaf.jpeg','central-multimidia.jpeg','image/jpeg',18677,'2026-09-14 11:54:02'),
    (3,3,NULL,'imagem','imagens/13c0bdc0-c7d2-492d-b76d-9b5a37dce23e.jpeg','auto-falante.jpeg','image/jpeg',18955,'2026-09-14 11:54:40'),
    (4,4,NULL,'imagem','imagens/2ecdd29f-8be0-43c2-9b7f-eabdc487273f.jpeg','subwoofer.jpeg','image/jpeg',4182,'2026-09-14 11:55:02'),
    (5,5,NULL,'imagem','imagens/cd0ebf58-9a95-4a71-8ecb-60f4a473effa.jpeg','bateria-60.jpeg','image/jpeg',25108,'2026-09-14 11:55:23'),
    (6,6,NULL,'imagem','imagens/ce59fb55-4759-463a-b99f-44ab86ab19ed.jpeg','bateria-70.jpeg','image/jpeg',25108,'2026-09-14 11:56:07'),
    (7,7,NULL,'imagem','imagens/838d2903-3eec-4ea8-8b75-d10de1141f96.jpg','bateria-moto.jpg','image/jpeg',87335,'2026-09-14 11:56:25'),
    (8,8,NULL,'imagem','imagens/ccd4f791-d29f-44ac-9652-001d9b249148.jpeg','cabo-rca.jpeg','image/jpeg',25479,'2026-09-14 11:58:29'),
    (9,9,NULL,'imagem','imagens/2ff348bb-2493-4839-b718-922135358821.jpeg','cabo-1-5-mm.jpeg','image/jpeg',8419,'2026-09-14 11:58:54'),
    (10,10,NULL,'imagem','imagens/bca5d897-2e8b-4978-92f8-d5f1dc897b59.png','csbo-10-mm.png','image/png',177095,'2026-09-14 11:59:12'),
    (11,11,NULL,'imagem','imagens/a7891410-81bc-4977-9a8b-7a2aa7b35634.png','conector-iso.png','image/png',528356,'2026-09-14 11:59:37'),
    (12,12,NULL,'imagem','imagens/88dc061e-5428-4086-8955-da5729f32244.png','lampada-h4.png','image/png',58723,'2026-09-14 12:00:03'),
    (13,13,NULL,'imagem','imagens/5ce9fd20-c52f-476a-b2e4-124132a4a943.png','lampada-h7.png','image/png',182085,'2026-09-14 12:00:20'),
    (14,14,NULL,'imagem','imagens/c1a67bcf-96fd-4b58-8b24-9dfc39a8520e.jpeg','barra-led.jpeg','image/jpeg',14951,'2026-09-14 12:00:47'),
    (15,15,NULL,'imagem','imagens/1adab5e9-e2df-4964-b587-b56b014f35e1.jpg','capa-banco.jpg','image/jpeg',65489,'2026-09-14 12:01:23'),
    (16,16,NULL,'imagem','imagens/b0942b13-ca3a-4413-a6ac-a74c45ce683b.png','capa-volante.png','image/png',54215,'2026-09-14 12:01:41'),
    (17,17,NULL,'imagem','imagens/a4b84263-2c8d-4775-8c6b-31b6e3a288e4.webp','capa-cambio.webp','image/webp',41460,'2026-09-14 12:01:59'),
    (18,18,NULL,'imagem','imagens/8003fff1-0c52-4b43-9c46-63b092f36bf1.webp','fusivel.webp','image/webp',18368,'2026-09-14 12:03:47'),
    (19,19,NULL,'imagem','imagens/9f8fd015-3217-4bcd-b3c4-3d7453db1d04.png','rele.png','image/png',32239,'2026-09-14 12:04:06'),
    (20,20,NULL,'imagem','imagens/ca909312-a2c4-47b4-9db9-2fd53d4b8d3c.webp','suporte-fusivel.webp','image/webp',22784,'2026-09-14 12:04:22'),
    (21,21,NULL,'imagem','imagens/3142d714-feed-4743-85a4-ee29286f9676.webp','abracadeira.webp','image/webp',26790,'2026-09-14 12:04:38');

INSERT INTO movimentacoes (
    id,
    item_id,
    usuario_id,
    tipo,
    quantidade,
    estoque_antes,
    estoque_depois,
    data,
    observacao
) VALUES
      (1, 1, 1, 'entrada', 10, 0, 10, '2026-08-14', 'Compra inicial de rádios Bluetooth'),
      (2, 1, 1, 'saida',    2, 10,  8, '2026-08-15', 'Venda para cliente'),
      (3, 2, 1, 'entrada',  6, 0,  6, '2026-08-14', 'Compra inicial de centrais multimídia'),
      (4, 2, 1, 'saida',    1, 6,  5, '2026-08-16', 'Venda para cliente'),
      (5, 3, 1, 'entrada', 16, 0, 16, '2026-08-15', 'Reposição de alto-falantes'),
      (6, 3, 1, 'saida',    2, 16, 14, '2026-08-17', 'Venda de alto-falantes'),
      (7, 4, 1, 'entrada',  4, 0,  4, '2026-08-16', 'Compra de subwoofers'),
      (8, 4, 1, 'saida',    1, 4,  3, '2026-08-18', 'Venda de subwoofer'),
      (9, 5, 1, 'entrada',  8, 0,  8, '2026-08-17', 'Compra de baterias automotivas'),
      (10, 5, 1, 'saida',   1, 8,  7, '2026-08-19', 'Venda de bateria'),
      (11, 6, 1, 'entrada', 5, 0, 5, '2026-08-18', 'Compra de baterias 70 Ah'),
      (12, 6, 1, 'saida',   1, 5, 4, '2026-08-20', 'Venda de bateria'),
      (13, 7, 1, 'entrada', 3, 0, 3, '2026-08-19', 'Compra de baterias de moto'),
      (14, 7, 1, 'saida',   1, 3, 2, '2026-08-21', 'Venda de bateria de moto'),
      (15, 8, 1, 'entrada', 20, 0, 20, '2026-08-20', 'Compra de cabos RCA'),
      (16, 8, 1, 'saida',    2, 20, 18, '2026-08-22', 'Venda de cabos RCA'),
      (17, 9, 1, 'entrada', 50, 0, 50, '2026-08-21', 'Compra de cabo para alto-falante'),
      (18, 9, 1, 'saida',    5, 50, 45, '2026-08-23', 'Venda de cabo por metro'),
      (19, 10, 1, 'entrada', 25, 0, 25, '2026-08-22', 'Compra de cabos de alimentação'),
      (20, 10, 1, 'saida',    3, 25, 22, '2026-08-24', 'Venda de cabos'),
      (21, 11, 1, 'entrada', 12, 0, 12, '2026-08-23', 'Compra de conectores ISO'),
      (22, 11, 1, 'saida',    1, 12, 11, '2026-08-25', 'Venda de conector ISO'),
      (23, 12, 1, 'entrada', 18, 0, 18, '2026-08-24', 'Compra de lâmpadas H4'),
      (24, 12, 1, 'saida',    2, 18, 16, '2026-08-26', 'Venda de lâmpadas'),
      (25, 13, 1, 'entrada',  5, 0,  5, '2026-08-25', 'Compra de lâmpadas H7'),
      (26, 13, 1, 'saida',    1, 5,  4, '2026-08-27', 'Venda de lâmpada'),
      (27, 14, 1, 'entrada', 10, 0, 10, '2026-08-26', 'Compra de barras LED'),
      (28, 14, 1, 'saida',    1, 10, 9, '2026-08-28', 'Venda de barra LED'),
      (29, 15, 1, 'entrada',  7, 0,  7, '2026-08-27', 'Compra de capas de banco'),
      (30, 15, 1, 'saida',    1, 7,  6, '2026-08-29', 'Venda de capa de banco'),
      (31, 16, 1, 'entrada', 15, 0, 15, '2026-08-28', 'Compra de capas de volante'),
      (32, 16, 1, 'saida',    2, 15, 13, '2026-08-30', 'Venda de capas de volante'),
      (33, 17, 1, 'entrada',  2, 0,  2, '2026-08-29', 'Compra de capas de câmbio'),
      (34, 17, 1, 'saida',    1, 2,  1, '2026-08-31', 'Venda de capa de câmbio'),
      (35, 18, 1, 'entrada', 40, 0, 40, '2026-08-30', 'Compra de fusíveis'),
      (36, 18, 1, 'saida',    2, 40, 38, '2026-09-01', 'Venda de fusíveis'),
      (37, 19, 1, 'entrada', 14, 0, 14, '2026-08-31', 'Compra de relés'),
      (38, 19, 1, 'saida',    2, 14, 12, '2026-09-02', 'Venda de relés'),
      (39, 20, 1, 'entrada',  4, 0,  4, '2026-09-01', 'Compra de suportes de fusíveis'),
      (40, 20, 1, 'saida',    1, 4,  3, '2026-09-03', 'Venda de suporte'),
      (41, 21, 1, 'entrada', 24, 0, 24, '2026-09-02', 'Compra de kits de abraçadeiras'),
      (42, 21, 1, 'saida',    4, 24, 20, '2026-09-14', 'Venda de kits');

INSERT INTO alertas (
    item_id,
    tipo,
    visualizado
) VALUES
      (7, 'estoque_baixo', 0),
      (13, 'estoque_baixo', 0),
      (17, 'estoque_baixo', 0),
      (20, 'estoque_baixo', 0);

CREATE OR REPLACE VIEW vw_alertas_estoque AS
SELECT
    i.id AS item_id,
    i.atualizado_em AS data_ocorrencia,
    i.nome AS item_nome,
    c.nome AS categoria_nome,
    u.abreviacao AS unidade_medida,
    i.quantidade_atual AS quantidade_atual,
    i.quantidade_minima AS quantidade_minima,
    CASE
        WHEN i.quantidade_atual = 0 THEN 'zerado'
        ELSE 'estoque_baixo'
        END AS tipo_alerta
FROM itens i
         INNER JOIN categorias c
                    ON i.categoria_id = c.id
         INNER JOIN unidades u
                    ON i.unidade_id = u.id
WHERE i.ativo = 1
  AND i.quantidade_atual <= i.quantidade_minima;

CREATE OR REPLACE VIEW vw_relatorio AS
SELECT
    (
        SELECT COUNT(*)
        FROM itens
        WHERE ativo = TRUE
    ) AS total_itens,
    (
        SELECT COUNT(*)
        FROM itens
        WHERE quantidade_atual > quantidade_minima
          AND ativo = TRUE
    ) AS itens_ok,
    (
        SELECT COUNT(*)
        FROM itens
        WHERE quantidade_atual <= quantidade_minima
          AND quantidade_atual > 0
          AND ativo = TRUE
    ) AS itens_alerta,
    (
        SELECT COUNT(*)
        FROM itens
        WHERE quantidade_atual = 0
          AND ativo = TRUE
    ) AS itens_zerados,
    (
        SELECT i.nome
        FROM movimentacoes m
                 INNER JOIN itens i
                            ON m.item_id = i.id
        ORDER BY m.criado_em DESC
         LIMIT 1
    ) AS ultima_mov_item,
    (
        SELECT tipo
        FROM movimentacoes
        ORDER BY criado_em DESC
        LIMIT 1
    ) AS ultima_mov_tipo,
    (
        SELECT criado_em
        FROM movimentacoes
        ORDER BY criado_em DESC
        LIMIT 1
    ) AS ultima_mov_data;

CREATE TABLE clientes (
                          id INT NOT NULL AUTO_INCREMENT,
                          nome VARCHAR(255) NOT NULL,
                          telefone VARCHAR(30) DEFAULT NULL,
                          criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (id),
                          KEY idx_clientes_nome (nome)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orcamentos (
                            id INT NOT NULL AUTO_INCREMENT,
                            cliente_id INT NOT NULL,
                            usuario_id INT DEFAULT NULL,
                            status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
                            observacao VARCHAR(500) DEFAULT NULL,
                            valor_total DOUBLE DEFAULT NULL,
                            criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
                            PRIMARY KEY (id),
                            KEY fk_orcamentos_cliente (cliente_id),
                            KEY fk_orcamentos_usuario (usuario_id),
                            CONSTRAINT fk_orcamentos_cliente
                                FOREIGN KEY (cliente_id)
                                    REFERENCES clientes (id),
                            CONSTRAINT fk_orcamentos_usuario
                                FOREIGN KEY (usuario_id)
                                    REFERENCES usuarios (id),
                            CONSTRAINT chk_orcamentos_status
                                CHECK (
                                    status IN (
                                               'PENDENTE',
                                               'ACEITO',
                                               'REJEITADO',
                                               'CONCLUIDO'
                                        )
                                    )
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orcamento_itens (
                                 id INT NOT NULL AUTO_INCREMENT,
                                 orcamento_id INT NOT NULL,
                                 item_id INT DEFAULT NULL,
                                 descricao VARCHAR(255) NOT NULL,
                                 quantidade INT NOT NULL,
                                 preco_unitario DOUBLE NOT NULL,
                                 PRIMARY KEY (id),
                                 KEY fk_orcamento_itens_orcamento (orcamento_id),
                                 KEY fk_orcamento_itens_item (item_id),
                                 CONSTRAINT fk_orcamento_itens_orcamento
                                     FOREIGN KEY (orcamento_id)
                                         REFERENCES orcamentos (id),
                                 CONSTRAINT fk_orcamento_itens_item
                                     FOREIGN KEY (item_id)
                                         REFERENCES itens (id),
                                 CONSTRAINT chk_orcamento_itens_quantidade
                                     CHECK (quantidade > 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE encomendas (
                            id INT NOT NULL AUTO_INCREMENT,
                            orcamento_id INT NOT NULL,
                            orcamento_item_id INT NOT NULL,
                            item_id INT DEFAULT NULL,
                            descricao VARCHAR(255) NOT NULL,
                            quantidade INT NOT NULL,
                            status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
                            criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            recebida_em DATETIME DEFAULT NULL,
                            concluida_em DATETIME DEFAULT NULL,
                            PRIMARY KEY (id),
                            KEY fk_encomendas_orcamento (orcamento_id),
                            KEY fk_encomendas_orcamento_item (orcamento_item_id),
                            KEY fk_encomendas_item (item_id),
                            CONSTRAINT fk_encomendas_orcamento
                                FOREIGN KEY (orcamento_id)
                                    REFERENCES orcamentos (id),
                            CONSTRAINT fk_encomendas_orcamento_item
                                FOREIGN KEY (orcamento_item_id)
                                    REFERENCES orcamento_itens (id),
                            CONSTRAINT fk_encomendas_item
                                FOREIGN KEY (item_id)
                                    REFERENCES itens (id),
                            CONSTRAINT chk_encomendas_status
                                CHECK (
                                    status IN (
                                               'PENDENTE',
                                               'RECEBIDA',
                                               'CONCLUIDA'
                                        )
                                    )
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;