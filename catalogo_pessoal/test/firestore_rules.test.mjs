import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const projectId = 'demo-catalogo-pessoal';
const rules = await readFile(new URL('../firestore.rules', import.meta.url), 'utf8');

test('Firestore rules allow the owner and reject other identities and invalid writes', async () => {
  const environment = await initializeTestEnvironment({
    projectId,
    firestore: { host: '127.0.0.1', port: 8080, rules },
  });

  try {
    await environment.clearFirestore();
    const alice = environment.authenticatedContext('alice').firestore();
    const bob = environment.authenticatedContext('bob').firestore();
    const anonymous = environment.unauthenticatedContext().firestore();
    const aliceTask = doc(alice, 'tarefas/task-1');

    await assertSucceeds(setDoc(aliceTask, {
      titulo: 'Revisar atividade',
      concluida: false,
      ownerId: 'alice',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(getDoc(aliceTask));
    await assertSucceeds(
      getDocs(query(collection(alice, 'tarefas'), where('ownerId', '==', 'alice'))),
    );
    await assertFails(getDocs(collection(alice, 'tarefas')));
    await assertSucceeds(updateDoc(aliceTask, {
      titulo: 'Atividade revisada',
      concluida: true,
      updatedAt: serverTimestamp(),
    }));

    await assertFails(getDoc(doc(bob, 'tarefas/task-1')));
    await assertFails(updateDoc(doc(bob, 'tarefas/task-1'), {
      titulo: 'Alteração indevida',
      updatedAt: serverTimestamp(),
    }));
    await assertFails(getDocs(collection(anonymous, 'tarefas')));
    await assertFails(updateDoc(aliceTask, {
      ownerId: 'bob',
      updatedAt: serverTimestamp(),
    }));
    await assertFails(setDoc(doc(alice, 'tarefas/forged-owner'), {
      titulo: 'Tarefa de outra pessoa',
      concluida: false,
      ownerId: 'bob',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }));
    await assertFails(setDoc(doc(alice, 'tarefas/invalid-title'), {
      titulo: '',
      concluida: false,
      ownerId: 'alice',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }));
    await assertFails(setDoc(doc(alice, 'tarefas/extra-field'), {
      titulo: 'Campo extra',
      concluida: false,
      ownerId: 'alice',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
      administrator: true,
    }));
    await assertSucceeds(deleteDoc(aliceTask));
  } finally {
    await environment.cleanup();
  }
});
