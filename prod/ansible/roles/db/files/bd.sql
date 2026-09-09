DROP DATABASE IF EXISTS stockflow;
CREATE DATABASE stockflow;
USE stockflow;

CREATE TABLE cargos (
                        id int NOT NULL AUTO_INCREMENT,
                        nome varchar(255) NOT NULL,
                        descricao varchar(255) DEFAULT NULL,
                        criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cargos VALUES
    (1,'Administrador','Cargo com acesso total ao sistema','2026-04-14 00:51:33');

CREATE TABLE permissoes (
                            id int NOT NULL AUTO_INCREMENT,
                            nome varchar(255) NOT NULL,
                            descricao varchar(255) NOT NULL,
                            PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO permissoes VALUES
                           (1,'GERENCIAR_USUARIOS','Permite gerenciar usuarios do sistema'),
                           (2,'GERENCIAR_CARGOS','Permite gerenciar cargos do sistema'),
                           (3,'CADASTRAR_ITENS','Permite cadastrar novos itens no estoque'),
                           (4,'EDITAR_ITENS','Permite editar itens do estoque'),
                           (5,'EXCLUIR_ITENS','Permite excluir ou inativar itens do estoque'),
                           (6,'REGISTRAR_ENTRADA','Permite registrar entradas de estoque'),
                           (7,'REGISTRAR_SAIDA','Permite registrar saidas de estoque'),
                           (8,'VER_RELATORIOS','Permite visualizar relatorios do sistema');

CREATE TABLE cargo_permissoes (
                                  cargo_id int NOT NULL,
                                  permissao_id int NOT NULL,
                                  PRIMARY KEY (cargo_id, permissao_id),
                                  KEY fk_cargo_permissoes_permissao (permissao_id),
                                  CONSTRAINT fk_cargo_permissoes_cargo FOREIGN KEY (cargo_id) REFERENCES cargos (id),
                                  CONSTRAINT fk_cargo_permissoes_permissao FOREIGN KEY (permissao_id) REFERENCES permissoes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO cargo_permissoes VALUES
                                 (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8);

CREATE TABLE unidades (
                          id int NOT NULL AUTO_INCREMENT,
                          nome varchar(255) NOT NULL,
                          abreviacao varchar(255) DEFAULT NULL,
                          PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO unidades VALUES
                         (1,'Unidade','UN'),
                         (2,'Par','PR'),
                         (3,'Metro','M');

CREATE TABLE categorias (
                            id int NOT NULL AUTO_INCREMENT,
                            nome varchar(255) NOT NULL,
                            criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categorias VALUES
                           (1,'Som Automotivo','2026-06-08 00:17:33'),
                           (2,'Baterias','2026-06-08 00:17:33'),
                           (3,'Cabos e Conectores','2026-06-08 00:17:33'),
                           (4,'Iluminacao','2026-06-08 00:17:33');

CREATE TABLE usuarios (
                          id INT NOT NULL AUTO_INCREMENT,
                          cargo_id int NOT NULL,
                          nome varchar(255) NOT NULL,
                          email varchar(255) NOT NULL,
                          senha_hash varchar(2000) NOT NULL,
                          ativo tinyint(1) NOT NULL DEFAULT '1',
                          ultimo_acesso datetime DEFAULT NULL,
                          criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (id),
                          UNIQUE KEY email (email),
                          KEY fk_usuarios_cargo (cargo_id),
                          CONSTRAINT fk_usuarios_cargo FOREIGN KEY (cargo_id) REFERENCES cargos (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO usuarios VALUES
    (1,1,'ADM','adm@email.com','$2a$10$FsYqdmjvhmmXTShZNqhGt.g8HHniASRM49aw5FP0GKKD1T0T4Rlkq',1,'2026-04-14 00:58:47','2026-04-14 00:51:41');

CREATE TABLE refresh_tokens (
                                id BIGINT NOT NULL AUTO_INCREMENT,
                                token_hash VARCHAR(100) NOT NULL,
                                expira_em TIMESTAMP NOT NULL,
                                revogado_em TIMESTAMP NULL,
                                usuario_id INT NOT NULL,

                                CONSTRAINT pk_refresh_tokens
                                    PRIMARY KEY (id),

                                CONSTRAINT fk_refresh_tokens_usuario
                                    FOREIGN KEY (usuario_id)
                                        REFERENCES usuarios(id)
                                        ON DELETE CASCADE
);

CREATE INDEX idx_refresh_token_usuario
    ON refresh_tokens(usuario_id);

CREATE INDEX idx_refresh_token_expira_em
    ON refresh_tokens(expira_em);
CREATE TABLE itens (
                       id int NOT NULL AUTO_INCREMENT,
                       categoria_id int NOT NULL,
                       unidade_id int NOT NULL,
                       nome varchar(255) NOT NULL,
                       quantidade_atual int NOT NULL DEFAULT '0',
                       quantidade_minima int NOT NULL DEFAULT '0',
                       preco_custo double DEFAULT NULL,
                       preco_venda double DEFAULT NULL,
                       ativo tinyint(1) NOT NULL DEFAULT '1',
                       criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       atualizado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       uri_imagem varchar(500) DEFAULT NULL,
                       nome_imagem varchar(255) DEFAULT NULL,
                       mime_type_imagem varchar(100) DEFAULT NULL,
                       tamanho_imagem int DEFAULT NULL,
                       PRIMARY KEY (id),
                       KEY fk_itens_categoria (categoria_id),
                       KEY fk_itens_unidade (unidade_id),
                       CONSTRAINT fk_itens_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id),
                       CONSTRAINT fk_itens_unidade FOREIGN KEY (unidade_id) REFERENCES unidades (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO itens VALUES
    (1,1,1,'Modulo Amplificador 400W',8,3,180,320,1,'2026-06-08 00:17:33','2026-06-08 00:17:33',
     'imagens/uuid-amplificador.jpg','amplificador.jpg','image/jpeg',102400);

CREATE TABLE movimentacoes (
                               id int NOT NULL AUTO_INCREMENT,
                               item_id int NOT NULL,
                               usuario_id int NOT NULL,
                               tipo varchar(20) NOT NULL,
                               quantidade int NOT NULL,
                               estoque_antes int NOT NULL,
                               estoque_depois int NOT NULL,
                               data date NOT NULL,
                               observacao varchar(255) DEFAULT NULL,
                               criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               uri_nota_entrada varchar(500) DEFAULT NULL,
                               nome_nota_entrada varchar(255) DEFAULT NULL,
                               mime_type_nota_entrada varchar(100) DEFAULT NULL,
                               tamanho_nota_entrada int DEFAULT NULL,
                               PRIMARY KEY (id),
                               KEY fk_movimentacoes_item (item_id),
                               KEY fk_movimentacoes_usuario (usuario_id),
                               CONSTRAINT fk_movimentacoes_item FOREIGN KEY (item_id) REFERENCES itens (id),
                               CONSTRAINT fk_movimentacoes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
                               CONSTRAINT chk_movimentacoes_tipo CHECK ((tipo in ('entrada','saida')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO movimentacoes VALUES
    (1,1,1,'entrada',5,3,8,'2026-04-15','Compra fornecedor NF 1042','2026-06-08 00:17:33',
     'notas/uuid-nf1042.pdf','nf-1042.pdf','application/pdf',204800);

CREATE TABLE alertas (
                         id int NOT NULL AUTO_INCREMENT,
                         item_id int NOT NULL,
                         tipo varchar(30) NOT NULL,
                         visualizado tinyint(1) NOT NULL DEFAULT '0',
                         criado_em datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         PRIMARY KEY (id),
                         KEY fk_alertas_item (item_id),
                         CONSTRAINT fk_alertas_item FOREIGN KEY (item_id) REFERENCES itens (id),
                         CONSTRAINT chk_alertas_tipo CHECK ((tipo in ('estoque_baixo','zerado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
         INNER JOIN categorias c ON i.categoria_id = c.id
         INNER JOIN unidades u ON i.unidade_id = u.id
WHERE i.ativo = 1
  AND i.quantidade_atual <= i.quantidade_minima;

CREATE OR REPLACE VIEW vw_relatorio AS
SELECT
    (SELECT COUNT(*) FROM itens WHERE ativo = true) AS total_itens,
    (SELECT COUNT(*) FROM itens WHERE quantidade_atual > quantidade_minima AND ativo = true) AS itens_ok,
    (SELECT COUNT(*) FROM itens WHERE quantidade_atual <= quantidade_minima AND quantidade_atual > 0 AND ativo = true) AS itens_alerta,
    (SELECT COUNT(*) FROM itens WHERE quantidade_atual = 0 AND ativo = true) AS itens_zerados,
    -- Dados da última movimentação
    (SELECT i.nome FROM movimentacoes m JOIN itens i ON m.item_id = i.id ORDER BY m.criado_em DESC LIMIT 1) AS ultima_mov_item,
    (SELECT tipo FROM movimentacoes ORDER BY criado_em DESC LIMIT 1) AS ultima_mov_tipo,
    (SELECT criado_em FROM movimentacoes ORDER BY criado_em DESC LIMIT 1) AS ultima_mov_data;