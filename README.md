# Psyes – Gestão para Psicólogos Autônomos

![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Em_Desenvolvimento-success?style=for-the-badge)

O **Psyes** é um aplicativo nativo para iOS projetado de ponta a ponta para otimizar a gestão da psicologia clínica. Como um produto comercial completo, o sistema centraliza o controle de pacientes, sessões e finanças para profissionais autônomos, entregando uma experiência fluida, segura e de altíssima performance.

---

## Visão Geral do Produto

O aplicativo foi desenhado para resolver as dores reais do dia a dia clínico, combinando ferramentas de produtividade com um modelo de assinatura integrado. 

* **Gestão de Pacientes e Prontuários:** Cadastro completo e acompanhamento histórico.
* **Controle de Sessões:** Organização de agenda com recursos de acompanhamento contínuo.
* **Saúde Financeira:** Módulo dedicado ao controle de pagamentos e fluxo de caixa do consultório.
* **Monetização Nativa:** Sistema de assinaturas e pagamentos In-App gerenciado diretamente via **StoreKit**.
* **Engajamento em Tempo Real:** Uso de **Live Activities** e **Push Notifications (APNs)** para manter o profissional sempre atualizado sobre eventos importantes e horários de sessões.

---

## Arquitetura e Tecnologias (Under the Hood)

O projeto foi construído com foco em escalabilidade, manutenção e reatividade, utilizando os padrões mais modernos do ecossistema Apple.

### Padrão Arquitetural
* **Clean Architecture + MVVM:** Estrutura rigorosamente dividida em múltiplas camadas para separação de responsabilidades:
  * `Router`: Gerenciamento unificado de navegação e fluxos de tela.
  * `Managers`: Classes utilitárias e gerenciamento de estado global.
  * `Service`: Comunicação externa, APIs e abstração do Backend.
  * `Repository`: Padrão de repositório para centralizar o acesso a dados (Cache Local vs Nuvem).
* **Programação Reativa:** Utilização intensiva do framework **Combine** nas `ViewModels` para um fluxo de dados declarativo e reativo nas interfaces.

### Backend e Sincronização
* **Serverless Stack:** Operações gerenciadas via **Firebase** (Firestore para banco de dados NoSQL, Firebase Auth para identidade e Cloud Functions para regras de negócio server-side).
* **Zero-Delay Sync:** Implementação de um robusto sistema de **cache nativo** que permite o funcionamento do app e a leitura de dados em tempo real sem latência de rede perceptível para o usuário.

---

## Segurança e Privacidade de Dados

Tratando-se de dados sensíveis de pacientes (prontuários e informações clínicas), a segurança foi tratada como prioridade máxima e desenvolvida seguindo princípios rigorosos de proteção:

* **Criptografia Avançada:** Uso nativo do **CryptoKit** para assegurar que os dados locais e em trânsito estejam ilegíveis para agentes externos.
* **Proteção Biométrica:** Autenticação de acesso ao app e a áreas sensíveis utilizando **Face ID e Touch ID** através do framework `LocalAuthentication`.

---

## Status do Projeto

* **2026 - Atual:** Desenvolvimento end-to-end concluído, integração de pagamentos finalizada e submissão completa para a App Store. O aplicativo atua como um negócio ativo na loja oficial da Apple.

---
*Este repositório serve como documentação de portfólio da arquitetura e das tecnologias utilizadas no produto comercial Psyes.*
