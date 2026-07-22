import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { google } from "googleapis";

admin.initializeApp();
const db = admin.firestore();

/**
 * FIREBASE CRON JOB: Gerador Mensal de Faturas e Sessões
 * Roda automaticamente no dia 1º de todo mês, às 02:00 da manhã.
 */
export const rotinaMensalPsicoFlow = onSchedule("0 2 1 * *", async (event) => {
    console.log("Iniciando rotina mensal de faturamento e agendamento...");

    const hoje = new Date();
    const anoAtual = hoje.getFullYear();
    const mesAtual = hoje.getMonth();

    const mesFormatado = String(mesAtual + 1).padStart(2, '0');
    const mesReferencia = `${anoAtual}/${mesFormatado}`;
    
    // Limite de projeção: último dia do mês seguinte
    const ultimoDiaProximoMes = new Date(anoAtual, mesAtual + 2, 0);

    try {
        const usersSnapshot = await db.collection("users").get();

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;

            // Busca os pacientes ATIVOS desse psicólogo
            const patientsSnapshot = await db.collection(`users/${userId}/patients`)
                .where("status", "==", "ativo")
                .get();

            const pacientesAtivosIds = patientsSnapshot.docs.map(doc => doc.id);

            // =========================================================
            // 1. FATURAMENTO E PAGAMENTOS
            // Substitui o MonthlyPaymentGeneratorService.gerarCobrancasAtuaisEFuturas
            // =========================================================
            for (const patientDoc of patientsSnapshot.docs) {
                const paciente = patientDoc.data();
                const pacienteId = patientDoc.id;

                const pagamentosSnapshot = await db.collection(`users/${userId}/payments`)
                    .where("pacienteID", "==", pacienteId)
                    .where("mesReferencia", "==", mesReferencia)
                    .get();

                if (pagamentosSnapshot.empty) {
                    const novoPagamentoRef = db.collection(`users/${userId}/payments`).doc();
                    await novoPagamentoRef.set({
                        id: novoPagamentoRef.id,
                        psicologoID: userId,
                        pacienteID: pacienteId,
                        mesReferencia: mesReferencia,
                        dataPagamento: null,
                        valor: paciente.valor || 0.0,
                        pago: false
                    });
                }
            }

            // =========================================================
            // 2. SESSÕES DA AGENDA
            // Substitui o SessionGeneratorService.projetarSessoesFuturas
            // =========================================================
            const regrasSnapshot = await db.collection(`users/${userId}/fixed_sessions`).get();
            const sessoesExistentesSnapshot = await db.collection(`users/${userId}/sessions`).get();
            const sessoesExistentes = sessoesExistentesSnapshot.docs.map(doc => doc.data());

            for (const regraDoc of regrasSnapshot.docs) {
                const regra = regraDoc.data();

                if (pacientesAtivosIds.includes(regra.pacienteID)) {
                    let dataAtual = new Date(hoje.getTime());
                    
                    while (dataAtual <= ultimoDiaProximoMes) {
                        const diaSemanaSwift = dataAtual.getDay() + 1;

                        if (diaSemanaSwift === regra.diaDaSemana) {
                            const dataSessao = new Date(dataAtual.getFullYear(), dataAtual.getMonth(), dataAtual.getDate(), 12, 0, 0);
                            
                            const jaExiste = sessoesExistentes.some(sessao => {
                                if (sessao.sessaoFixaID !== regra.id) return false;
                                const dataSessaoExistente = sessao.dataDaSessão.toDate();
                                return dataSessaoExistente.getDate() === dataSessao.getDate() &&
                                       dataSessaoExistente.getMonth() === dataSessao.getMonth() &&
                                       dataSessaoExistente.getFullYear() === dataSessao.getFullYear();
                            });

                            if (!jaExiste) {
                                const novaSessaoRef = db.collection(`users/${userId}/sessions`).doc();
                                await novaSessaoRef.set({
                                    id: novaSessaoRef.id,
                                    psicologoID: userId,
                                    pacienteID: regra.pacienteID,
                                    sessaoFixaID: regra.id,
                                    dataDaSessão: admin.firestore.Timestamp.fromDate(dataSessao),
                                    status: "agendada",
                                    modalidade: regra.modalidade,
                                    horaInicio: regra.horaInicio
                                });
                            }
                        }
                        dataAtual.setDate(dataAtual.getDate() + 1);
                    }
                }
            }
        }
        console.log("✅ Manutenção mensal concluída com sucesso!");
    } catch (error) {
        console.error("❌ Erro na rotina mensal: ", error);
    }
});

/**
 * BOTÃO DE PÂNICO: Trava de Segurança Financeira
 * Desativa o plano Blaze automaticamente se o orçamento for atingido.
 */
export const cortarFaturamentoSeNecessario = onMessagePublished("orcamento-estourado", async (event) => {
    try {
        const pubSubMessage = event.data.message;
        
        // Decodifica o aviso enviado pelo Google Cloud Billing
        const messageString = pubSubMessage.data
            ? Buffer.from(pubSubMessage.data, 'base64').toString()
            : '{}';
            
        const budgetNotification = JSON.parse(messageString);
        
        // Verifica se o custo atual atingiu ou ultrapassou o limite estabelecido
        const costAmount = budgetNotification.costAmount || 0;
        const budgetAmount = budgetNotification.budgetAmount || 0;

        console.log(`⚠️ Alerta de Orçamento! Gasto atual: ${costAmount} de ${budgetAmount}`);

        if (costAmount >= budgetAmount) {
            const projectId = process.env.GCP_PROJECT || "psyes-17598";
            
            // Autentica com os privilégios do Google Cloud
            const auth = new google.auth.GoogleAuth({
                scopes: ['https://www.googleapis.com/auth/cloud-billing'],
            });
            const billing = google.cloudbilling({
                version: 'v1',
                auth: auth,
            });

            const projectBillingInfoName = `projects/${projectId}/billingInfo`;

            // COMANDO DE BLOQUEIO: Remove a conta de faturamento do projeto
            await billing.projects.updateBillingInfo({
                name: projectBillingInfoName,
                requestBody: {
                    billingAccountName: "", // String vazia desvincula o cartão na hora
                },
            });

            console.log(`🚨 SEGURANÇA ATIVADA: Faturamento do projeto ${projectId} foi desativado com sucesso devido a estouro de orçamento!`);
        }
    } catch (error) {
        console.error("❌ Erro ao tentar cortar o faturamento automaticamente:", error);
    }
});